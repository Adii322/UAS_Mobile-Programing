import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/data/models/daily_step_entry.dart';
import 'package:young_care/app/data/repositories/daily_steps_repository.dart';

/// Handles Bluetooth LE connection with the ESP32 device and exposes
/// health telemetry values (steps, heart rate, SpO2) to the rest of the app.
class BluetoothController extends GetxController {
  static const String targetDeviceName = 'ESP32_HealthTracker';
  static const Duration _vitalsRequestCooldown = Duration(seconds: 5);
  static const Duration _dailyStepsFlushInterval = Duration(minutes: 15);
  static const String _dailyStepsCacheKey = 'daily_steps_cache';
  static const String _dailyStepsLastStepKey = 'daily_steps_last_step';
  static const int _dailyStepsMaxCachedEntries = 1000;
  static const Duration _dailyStepsRetention = Duration(days: 7);

  // Preferred service & characteristic UUIDs. The controller will try these first,
  // then fall back to any characteristic that supports the required properties.
  static final List<Guid> _preferredServiceUuids = [
    Guid('12345678-1234-1234-1234-1234567890AB'),
    Guid('0000FFE0-0000-1000-8000-00805F9B34FB'),
  ];
  static final List<Guid> _preferredCharacteristicUuids = [
    Guid('ABCD1234-5678-90AB-CDEF-1234567890AB'),
    Guid('0000FFE1-0000-1000-8000-00805F9B34FB'),
  ];

  final RxBool isPermissionGranted = false.obs;
  final RxBool isBluetoothEnabled = true.obs;
  final RxBool isScanning = false.obs;
  final RxBool isConnecting = false.obs;
  final RxBool isConnected = false.obs;
  final RxString connectionMessage =
      'Menunggu koneksi perangkat ESP32_HealthTracker...'.obs;
  final RxBool isConnectionBannerVisible = true.obs;
  final RxnString lastError = RxnString();

  final RxnInt steps = RxnInt();
  final RxnInt heartRate = RxnInt();
  final RxnInt spo2 = RxnInt();
  final Rxn<DateTime> lastDataReceivedAt = Rxn<DateTime>();

  final GetStorage _storage = GetStorage();
  final DailyStepsRepository _dailyStepsRepository = DailyStepsRepository();
  final UserController _userController = Get.find<UserController>();

  BluetoothDevice? _device;
  DeviceIdentifier? _lastDeviceId;
  BluetoothCharacteristic? _notifyCharacteristic;
  BluetoothCharacteristic? _commandCharacteristic;

  StreamSubscription<BluetoothAdapterState>? _adapterStateSub;
  StreamSubscription<List<ScanResult>>? _scanResultsSub;
  StreamSubscription<bool>? _isScanningSub;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSub;
  StreamSubscription<List<int>>? _characteristicSub;

  Timer? _dailyStepsFlushTimer;
  Timer? _bannerAutoHideTimer;
  Worker? _userAuthWorker;
  bool _permissionRequested = false;
  DateTime? _lastVitalsRequestAt;
  bool _isDiscoveringServices = false;
  Completer<void>? _discoverServicesCompleter;
  bool _isFlushingDailySteps = false;
  int? _lastCachedStepValue;

  @override
  void onInit() {
    super.onInit();
    _listenAdapterState();
    _listenScanResults();
    _listenIsScanning();
    _ensureSetup();
    _initDailyStepsSync();
    _listenUserAuthenticationChanges();
  }

  @override
  void onClose() {
    _dailyStepsFlushTimer?.cancel();
    _bannerAutoHideTimer?.cancel();
    _characteristicSub?.cancel();
    _connectionStateSub?.cancel();
    _scanResultsSub?.cancel();
    _isScanningSub?.cancel();
    _adapterStateSub?.cancel();
    _userAuthWorker?.dispose();
    _device?.disconnect();
    super.onClose();
  }

  /// Exposed health data as a convenient immutable snapshot.
  HealthTelemetry get telemetry => HealthTelemetry(
        steps: steps.value,
        heartRate: heartRate.value,
        spo2: spo2.value,
        lastUpdatedAt: lastDataReceivedAt.value,
      );

  /// Trigger a manual reconnect attempt.
  Future<void> retryConnection() async {
    _showConnectionBanner();
    lastError.value = null;
    connectionMessage.value = 'Mencoba menghubungkan ulang ke perangkat...';
    await _disconnectCurrentDevice();
    await _ensureSetup(force: true);
  }

  /// Explicitly asks the ESP32 device to send heart rate & SpO2 data.
  Future<void> requestVitalSigns() async {
    await _sendVitalsRequest(force: true);
  }

  Future<HealthTelemetry?> requestVitalSignsSnapshot({
    Duration timeout = const Duration(seconds: 5),
    Duration minWait = Duration.zero,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    final DateTime? previousUpdate = lastDataReceivedAt.value;

    try {
      await requestVitalSigns();
    } catch (_) {
      // Ignore request errors and fall back to existing telemetry.
    }

    try {
      await lastDataReceivedAt.stream
          .where(
            (DateTime? timestamp) =>
                timestamp != null && timestamp != previousUpdate,
          )
          .first
          .timeout(timeout);
    } on TimeoutException {
      // Ignore timeout and return the latest known telemetry.
    } catch (_) {
      // Ignore other stream errors.
    }

    final Duration elapsed = stopwatch.elapsed;
    if (minWait > elapsed) {
      await Future.delayed(minWait - elapsed);
    }

    return telemetry;
  }

  Future<void> _ensureSetup({bool force = false}) async {
    _log(
      'ensureSetup(force: $force, enabled: ${isBluetoothEnabled.value}, '
      'connected: ${isConnected.value})',
    );
    if (!force && (!isBluetoothEnabled.value || isConnected.value)) {
      _log('ensureSetup diabaikan (force=false & sudah siap).');
      return;
    }

    final granted = await _ensurePermissions();
    if (!granted) {
      lastError.value =
          'Izin Bluetooth diperlukan untuk terhubung ke ESP32_HealthTracker.';
      connectionMessage.value =
          'Izin Bluetooth belum diberikan. Mohon izinkan akses.';
      return;
    }

    await _searchAndConnect();
  }

  Future<bool> _ensurePermissions() async {
    _log('Memastikan izin Bluetooth & lokasi tersedia.');
    if (isPermissionGranted.value && _permissionRequested && !kIsWeb) {
      _log('Izin sudah diberikan sebelumnya, tidak perlu meminta ulang.');
      return true;
    }

    if (kIsWeb) {
      isPermissionGranted.value = true;
      _log('Platform web, izin otomatis dianggap diberikan.');
      return true;
    }

    _permissionRequested = true;

    final List<Permission> requiredPermissions = <Permission>[
      if (Platform.isAndroid) ...[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ],
      if (Platform.isIOS) Permission.bluetooth,
    ];

    final Map<Permission, PermissionStatus> statuses =
        await requiredPermissions.request();

    final bool granted = statuses.values.every(
      (status) =>
          status.isGranted ||
          status.isLimited ||
          status == PermissionStatus.provisional,
    );

    isPermissionGranted.value = granted;
    _log('Hasil permintaan izin: $granted');
    return granted;
  }

  void _listenAdapterState() {
    _adapterStateSub = FlutterBluePlus.adapterState.listen((state) {
      _log('Adapter state berubah: $state');
      isBluetoothEnabled.value = state == BluetoothAdapterState.on;

      if (!isBluetoothEnabled.value) {
        connectionMessage.value = 'Bluetooth dimatikan. Aktifkan untuk terhubung.';
        lastError.value = 'Bluetooth adaptor sedang nonaktif.';
        _handleDisconnection();
      } else {
        connectionMessage.value =
            'Bluetooth aktif. Mencari perangkat $targetDeviceName...';
        lastError.value = null;
        _ensureSetup(force: true);
      }
    });
  }

  void _listenScanResults() {
    _scanResultsSub = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isEmpty || isConnected.value) return;
      for (final ScanResult result in results) {
        final String candidateName = result.device.platformName.isNotEmpty
            ? result.device.platformName
            : result.advertisementData.advName;
        if (candidateName == targetDeviceName) {
          _log('Perangkat target ditemukan: ${result.device.remoteId}');
          _onTargetDeviceFound(result.device);
          break;
        }
      }
    });
  }

  void _listenIsScanning() {
    _isScanningSub = FlutterBluePlus.isScanning.listen((scanning) {
      _log('Status pemindaian berubah: $scanning');
      isScanning.value = scanning;
      if (!scanning && !isConnected.value && isBluetoothEnabled.value) {
        connectionMessage.value =
            'Perangkat belum ditemukan. Ketuk Coba lagi untuk mencoba ulang.';
        _scheduleConnectionBannerAutoHide();
      }
    });
  }

  Future<void> _searchAndConnect() async {
    if (!isBluetoothEnabled.value || !isPermissionGranted.value) return;
    if (FlutterBluePlus.isScanningNow) return;
    if (isConnected.value || isConnecting.value) return;

    _log('Memulai pemindaian perangkat.');
    connectionMessage.value =
        'Mencari perangkat $targetDeviceName melalui Bluetooth...';
    lastError.value = null;
    try {
      await FlutterBluePlus.startScan(
        withNames: const [targetDeviceName],
        timeout: const Duration(seconds: 6),
      );
      _log('Pemindaian dimulai.');
    } catch (error) {
      lastError.value = 'Gagal memulai pemindaian: $error';
      connectionMessage.value =
          'Tidak dapat memulai pemindaian. Pastikan Bluetooth aktif.';
      _log('Pemindaian gagal dimulai: $error');
      _scheduleConnectionBannerAutoHide();
    }
  }

  void _onTargetDeviceFound(BluetoothDevice device) {
    _log('Menghentikan pemindaian & mencoba koneksi ke ${device.remoteId}.');
    FlutterBluePlus.stopScan();
    _connectToDevice(device);
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (isConnected.value || isConnecting.value) return;

    _device = device;
    _lastDeviceId = device.remoteId;
    isConnecting.value = true;
    connectionMessage.value = 'Menghubungkan ke $targetDeviceName...';
    _log('Menghubungkan ke perangkat ${device.remoteId}.');

    try {
      _connectionStateSub?.cancel();
      _connectionStateSub =
          device.connectionState.listen(_handleConnectionState);
      device.cancelWhenDisconnected(
        _connectionStateSub!,
        next: true,
        delayed: true,
      );

      await device.connect(
        license: License.free,
        timeout: const Duration(seconds: 15),
      );
      _log('Permintaan koneksi dikirim.');
    } on FlutterBluePlusException catch (error) {
      lastError.value = error.toString();
      connectionMessage.value =
          'Gagal terhubung ke perangkat. ${error.description ?? ''}';
      isConnecting.value = false;
      _log('Koneksi gagal (FlutterBluePlusException): $error');
      _scheduleConnectionBannerAutoHide();
    } catch (error) {
      lastError.value = error.toString();
      connectionMessage.value = 'Gagal terhubung ke perangkat.';
      isConnecting.value = false;
      _log('Koneksi gagal: $error');
      _scheduleConnectionBannerAutoHide();
    }
  }

  void _handleConnectionState(BluetoothConnectionState state) {
    _log('State koneksi berubah: $state');
    if (state == BluetoothConnectionState.connected) {
      _cancelConnectionBannerAutoHide();
      isConnected.value = true;
      isConnecting.value = false;
      connectionMessage.value = 'Terhubung ke $targetDeviceName.';
      lastError.value = null;
      _discoverServices();
    } else if (state == BluetoothConnectionState.disconnected) {
      _handleDisconnection();
    }
  }

  Future<void> _discoverServices() async {
    if (_isDiscoveringServices) {
      _log('Menunggu proses discover services yang sedang berjalan.');
      await _discoverServicesCompleter?.future;
      return;
    }

    BluetoothDevice? device = _device;
    if (device == null || !(device.isConnected)) {
      final DeviceIdentifier? remoteId = _lastDeviceId;
      if (remoteId != null) {
        final List<BluetoothDevice> connectedDevices =
            await FlutterBluePlus.connectedDevices;
        device = connectedDevices.firstWhereOrNull(
          (candidate) => candidate.remoteId == remoteId,
        );
        if (device != null) {
          _log(
            'Referensi perangkat dipulihkan untuk ${device.remoteId}.',
          );
          _device = device;
        }
      }
    }

    if (device == null || !device.isConnected) return;

    _isDiscoveringServices = true;
    final Completer<void> completer = Completer<void>();
    _discoverServicesCompleter = completer;

    try {
      final List<BluetoothService> services =
          await device.discoverServices(timeout: 15);
      _log('Discover services: ${services.length} layanan ditemukan.');
      for (final BluetoothService service in services) {
        final String prefix =
            service.isPrimary ? 'Primary' : 'Secondary';
        _log(
          'Service [$prefix] ${service.uuid} '
          '(${service.characteristics.length} characteristic)',
        );
        for (final BluetoothCharacteristic characteristic
            in service.characteristics) {
          _log(
            ' └─ Characteristic ${characteristic.uuid} '
            '[${_describeProperties(characteristic.properties)}]',
          );
        }
      }

      final BluetoothCharacteristic? candidate =
          _locatePreferredCharacteristic(services);

      _log('Karakteristik notify terpilih: ${candidate?.uuid}');

      if (candidate == null) {
        lastError.value =
            'Tidak menemukan karakteristik notifikasi pada perangkat.';
        connectionMessage.value =
            'Perangkat terhubung tetapi tidak ada data yang dapat dibaca.';
        return;
      }

      await candidate.setNotifyValue(true);
      _notifyCharacteristic = candidate;
      _commandCharacteristic =
          _locatePreferredCommandCharacteristic(services, candidate);
      if (_commandCharacteristic == null &&
          (candidate.properties.write ||
              candidate.properties.writeWithoutResponse)) {
        _commandCharacteristic = candidate;
      }
      _log(
        'Karakteristik command: ${_commandCharacteristic?.uuid ?? candidate.uuid}',
      );
      _lastVitalsRequestAt = null;
      _characteristicSub?.cancel();
      _characteristicSub = candidate.onValueReceived.listen(_handleIncomingData);
      device.cancelWhenDisconnected(_characteristicSub!);
      connectionMessage.value =
          'Menerima data dari perangkat $targetDeviceName.';
    } catch (error) {
      lastError.value = 'Gagal membaca layanan: $error';
      connectionMessage.value =
          'Perangkat terhubung tetapi layanan tidak dapat dibaca.';
      _log('Gagal discover services: $error');
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
      _isDiscoveringServices = false;
      _discoverServicesCompleter = null;
    }
  }

  BluetoothCharacteristic? _locatePreferredCharacteristic(
    List<BluetoothService> services,
  ) {
    final BluetoothService? preferredService = services.firstWhereOrNull(
      (svc) => _preferredServiceUuids.contains(svc.uuid),
    );

    if (preferredService != null) {
      _log(
        'Mencoba karakteristik dari service preferensi ${preferredService.uuid}',
      );
      final BluetoothCharacteristic? preferredCharacteristic =
          preferredService.characteristics.firstWhereOrNull(
        (chr) =>
            _preferredCharacteristicUuids.contains(chr.uuid) &&
            (chr.properties.notify || chr.properties.indicate),
      );
      if (preferredCharacteristic == null) {
        _log(
          'Tidak menemukan karakteristik preferensi pada service '
          '${preferredService.uuid}.',
        );
      }
      if (preferredCharacteristic != null) {
        return preferredCharacteristic;
      }
    }

    final Iterable<BluetoothCharacteristic> allCharacteristics =
        services.expand((service) => service.characteristics);

    final BluetoothCharacteristic? notifyAndWrite =
        allCharacteristics.firstWhereOrNull(
      (chr) =>
          (chr.properties.notify || chr.properties.indicate) &&
          (chr.properties.write || chr.properties.writeWithoutResponse),
    );
    if (notifyAndWrite != null) {
      _log(
        'Memakai karakteristik yang mendukung notify & write: '
        '${notifyAndWrite.uuid}',
      );
    }
    if (notifyAndWrite != null) return notifyAndWrite;

    final BluetoothCharacteristic? notifyOnly =
        allCharacteristics.firstWhereOrNull(
      (chr) => chr.properties.notify || chr.properties.indicate,
    );
    if (notifyOnly == null) {
      _log('Tidak menemukan karakteristik dengan properti notify/indicate.');
    }
    return notifyOnly;
  }

  BluetoothCharacteristic? _locatePreferredCommandCharacteristic(
    List<BluetoothService> services,
    BluetoothCharacteristic? notifyCharacteristic,
  ) {
    if (notifyCharacteristic != null &&
        (notifyCharacteristic.properties.write ||
            notifyCharacteristic.properties.writeWithoutResponse)) {
      _log(
        'Karakteristik notify juga mendukung write, menggunakan '
        '${notifyCharacteristic.uuid} untuk command.',
      );
      return notifyCharacteristic;
    }

    final Iterable<BluetoothCharacteristic> allCharacteristics =
        services.expand((service) => service.characteristics);

    final BluetoothCharacteristic? preferredCommand =
        allCharacteristics.firstWhereOrNull(
      (chr) =>
          _preferredCharacteristicUuids.contains(chr.uuid) &&
          (chr.properties.write || chr.properties.writeWithoutResponse),
    );
    if (preferredCommand != null) {
      _log('Menggunakan karakteristik command preferensi ${preferredCommand.uuid}.');
    }
    if (preferredCommand != null) return preferredCommand;

    final BluetoothCharacteristic? command =
        allCharacteristics.firstWhereOrNull(
      (chr) =>
          (chr.properties.write || chr.properties.writeWithoutResponse) &&
          chr != notifyCharacteristic,
    );
    if (command == null) {
      _log('Tidak menemukan karakteristik write untuk command.');
    }
    return command;
  }

  String _describeProperties(CharacteristicProperties properties) {
    final List<String> flags = [];
    if (properties.read) flags.add('READ');
    if (properties.write) flags.add('WRITE');
    if (properties.writeWithoutResponse) flags.add('WRITE_NR');
    if (properties.notify) flags.add('NOTIFY');
    if (properties.indicate) flags.add('INDICATE');
    if (properties.broadcast) flags.add('BROADCAST');
    if (properties.extendedProperties) flags.add('EXTENDED');
    if (properties.authenticatedSignedWrites) flags.add('SIGNED');
    if (flags.isEmpty) flags.add('NONE');
    return flags.join(', ');
  }

  void _handleIncomingData(List<int> rawValue) {
    if (rawValue.isEmpty) return;

    final String payload =
        const Utf8Decoder(allowMalformed: true).convert(rawValue).trim();
    _log(
      'Data masuk (length=${rawValue.length}): '
      '${payload.length > 120 ? payload.substring(0, 120) + '...' : payload}',
    );

    if (payload.isNotEmpty && _parseStringPayload(payload)) {
      return;
    }

    // Fallback: treat payload as three unsigned 16-bit integers (steps, HR, SpO2).
    if (rawValue.length >= 6) {
      final int parsedSteps = _readUint16(rawValue, 0);
      final int parsedHr = _readUint16(rawValue, 2);
      final int parsedSpo2 = _readUint16(rawValue, 4);
      _updateTelemetry(
        steps: parsedSteps,
        heartRate: parsedHr,
        spo2: parsedSpo2,
      );
    }
  }

  bool _parseStringPayload(String payload) {
    final String sanitized = payload.trim();
    if (sanitized.isEmpty) return false;

    if (_tryParseJsonPayload(sanitized)) return true;
    if (_tryParseKeyValuePayload(sanitized)) return true;
    if (_tryParseDelimitedPayload(sanitized)) return true;

    return false;
  }

  bool _tryParseJsonPayload(String payload) {
    try {
      final dynamic decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        final int? parsedSteps = _safeInt(decoded['steps']);
        final int? parsedHr =
            _safeInt(decoded['hr']);
        final int? parsedSpo2 =
            _safeInt(decoded['spo2']);

        if (parsedSteps != null || parsedHr != null || parsedSpo2 != null) {
          _updateTelemetry(
            steps: parsedSteps,
            heartRate: parsedHr,
            spo2: parsedSpo2,
          );
          _log(
            'JSON payload terdeteksi: steps=$parsedSteps, '
            'hr=$parsedHr, spo2=$parsedSpo2',
          );
          return true;
        }
      }
    } catch (_) {
      // Ignore JSON parsing errors and fall through to other parsers.
    }
    return false;
  }

  bool _tryParseKeyValuePayload(String payload) {
    final RegExp regex =
        RegExp(r'(\w+)\s*[:=]\s*([0-9]+)', caseSensitive: false);
    final Iterable<RegExpMatch> matches = regex.allMatches(payload);
    if (matches.isEmpty) return false;

    int? parsedSteps;
    int? parsedHr;
    int? parsedSpo2;

    for (final RegExpMatch match in matches) {
      final String key = match.group(1)!.toLowerCase();
      final int value = int.parse(match.group(2)!);
      if (key.contains('step')) {
        parsedSteps = value;
      } else if (key.contains('hr') ||
          key.contains('heart') ||
          key.contains('bpm')) {
        parsedHr = value;
      } else if (key.contains('spo2') ||
          key.contains('oxygen') ||
          key.contains('o2')) {
        parsedSpo2 = value;
      }
    }

    if (parsedSteps != null || parsedHr != null || parsedSpo2 != null) {
      _updateTelemetry(
        steps: parsedSteps,
        heartRate: parsedHr,
        spo2: parsedSpo2,
      );
      _log(
        'Key-value payload terdeteksi: steps=$parsedSteps, '
        'hr=$parsedHr, spo2=$parsedSpo2',
      );
      return true;
    }
    return false;
  }

  bool _tryParseDelimitedPayload(String payload) {
    final List<String> segments = payload
        .split(RegExp(r'[;,]'))
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (segments.length < 3) return false;

    final List<int?> numbers = segments.map(_safeInt).toList();
    if (numbers.whereType<int>().length < 3) return false;

    final int? parsedSteps = numbers.isNotEmpty ? numbers[0] : null;
    final int? parsedHr = numbers.length > 1 ? numbers[1] : null;
    final int? parsedSpo2 = numbers.length > 2 ? numbers[2] : null;

    _updateTelemetry(
      steps: parsedSteps,
      heartRate: parsedHr,
      spo2: parsedSpo2,
    );
    _log(
      'Delimited payload terdeteksi: steps=$parsedSteps, '
      'hr=$parsedHr, spo2=$parsedSpo2',
    );
    return true;
  }

  void _updateTelemetry({int? steps, int? heartRate, int? spo2}) {
    bool didUpdate = false;
    if (steps != null) {
      this.steps.value = steps;
      _cacheDailyStepSample(steps);
      didUpdate = true;
    }
    if (heartRate != null) {
      this.heartRate.value = heartRate;
      didUpdate = true;
    }
    if (spo2 != null) {
      this.spo2.value = spo2;
      didUpdate = true;
    }
    if (didUpdate) {
      lastDataReceivedAt.value = DateTime.now();
    }
  }

  int _readUint16(List<int> data, int offset) {
    if (data.length < offset + 2) return 0;
    return data[offset] | (data[offset + 1] << 8);
  }

  int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<void> _disconnectCurrentDevice() async {
    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (_) {
        // ignore disconnect errors
      }
    }
    _handleDisconnection();
  }

  void _handleDisconnection() {
    _log('Menangani pemutusan koneksi.');
    isConnecting.value = false;
    isConnected.value = false;
    _notifyCharacteristic = null;
    _commandCharacteristic = null;
    _lastVitalsRequestAt = null;
    _characteristicSub?.cancel();
    _characteristicSub = null;
    _device = null;
    connectionMessage.value =
        'Tidak terhubung ke $targetDeviceName. Ketuk Coba lagi untuk mencoba ulang.';
    _scheduleConnectionBannerAutoHide();
  }

  Future<void> _ensureTelemetryCharacteristics() async {
    final bool notifyReady = _notifyCharacteristic != null;
    final bool commandReady = _commandCharacteristic != null;

    if (notifyReady && commandReady) return;

    if (notifyReady && !commandReady) {
      final CharacteristicProperties properties =
          _notifyCharacteristic!.properties;
      if (properties.write || properties.writeWithoutResponse) {
        _commandCharacteristic = _notifyCharacteristic;
        return;
      }
    }

    if (!isConnected.value) {
      _log(
        'Tidak dapat memastikan karakteristik karena perangkat belum terhubung.',
      );
      return;
    }

    await _discoverServices();

    if (_notifyCharacteristic == null) {
      _log('Karakteristik notify masih null setelah discover.');
    }
    if (_commandCharacteristic == null) {
      _log('Karakteristik command masih null setelah discover.');
    }
  }

  void _initDailyStepsSync() {
    _startDailyStepsFlushTimer();
    final List<DailyStepEntry> cached = _readCachedDailySteps();
    if (cached.isNotEmpty) {
      _lastCachedStepValue = cached.last.step;
    } else {
      _lastCachedStepValue = _readPersistedLastStepValue();
    }
    unawaited(_flushPendingDailySteps());
  }

  void _listenUserAuthenticationChanges() {
    final String? userId = _userController.userId;
    if (userId != null && userId.isNotEmpty) {
      unawaited(_flushPendingDailySteps());
    }

    _userAuthWorker ??= ever(
      _userController.user,
      (dynamic user) {
        if (user != null) {
          unawaited(_flushPendingDailySteps());
        }
      },
    );
  }

  void _startDailyStepsFlushTimer() {
    _dailyStepsFlushTimer ??= Timer.periodic(
      _dailyStepsFlushInterval,
      (_) => unawaited(_flushPendingDailySteps()),
    );
  }

  void _cacheDailyStepSample(int stepValue) {
    if (stepValue < 0) return;
    if (_lastCachedStepValue != null && _lastCachedStepValue == stepValue) {
      _persistLastStepValue(stepValue);
      return;
    }
    final DateTime now = DateTime.now();
    final List<DailyStepEntry> cached = _readCachedDailySteps();
    final DailyStepEntry? last = cached.isNotEmpty ? cached.last : null;

    if (last != null) {
      if (last.step == stepValue) {
        _lastCachedStepValue = stepValue;
        _persistLastStepValue(stepValue);
        return;
      }

      if (_isSameDay(last.createdAt, now)) {
        cached[cached.length - 1] = last.copyWith(
          step: stepValue,
          createdAt: now,
          userId: _userController.userId,
        );
        final List<DailyStepEntry> pruned = _pruneDailyStepsCache(cached);
        _lastCachedStepValue = stepValue;
        _persistLastStepValue(stepValue);
        unawaited(_writeCachedDailySteps(pruned));
        return;
      }
    }

    cached.add(
      DailyStepEntry(
        step: stepValue,
        createdAt: now,
        userId: _userController.userId,
      ),
    );

    final List<DailyStepEntry> pruned = _pruneDailyStepsCache(cached);
    _lastCachedStepValue = stepValue;
    _persistLastStepValue(stepValue);
    unawaited(_writeCachedDailySteps(pruned));
  }

  List<DailyStepEntry> _pruneDailyStepsCache(List<DailyStepEntry> entries) {
    final DateTime cutoff = DateTime.now().subtract(_dailyStepsRetention);
    final List<DailyStepEntry> recent = entries
        .where((DailyStepEntry entry) => entry.createdAt.isAfter(cutoff))
        .toList();

    if (recent.length <= _dailyStepsMaxCachedEntries) {
      return recent;
    }
    return recent.sublist(recent.length - _dailyStepsMaxCachedEntries);
  }

  List<DailyStepEntry> _readCachedDailySteps() {
    final dynamic raw = _storage.read(_dailyStepsCacheKey);
    if (raw is List) {
      return raw
          .map(DailyStepEntry.fromStorageJson)
          .whereType<DailyStepEntry>()
          .toList();
    }
    return <DailyStepEntry>[];
  }

  Future<void> _writeCachedDailySteps(List<DailyStepEntry> entries) {
    final List<Map<String, dynamic>> serialized =
        entries.map((DailyStepEntry entry) => entry.toStorageJson()).toList();
    return _storage.write(_dailyStepsCacheKey, serialized);
  }

  int? _readPersistedLastStepValue() {
    final dynamic raw = _storage.read(_dailyStepsLastStepKey);
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  void _persistLastStepValue(int? value) {
    if (value == null) {
      unawaited(_storage.remove(_dailyStepsLastStepKey));
      return;
    }
    unawaited(_storage.write(_dailyStepsLastStepKey, value));
  }

  Future<void> _flushPendingDailySteps() async {
    if (_isFlushingDailySteps) return;

    final List<DailyStepEntry> cached = _readCachedDailySteps();
    if (cached.isEmpty) return;

    final String? userId = _userController.userId;
    if (userId == null || userId.isEmpty) {
      _log('Sinkronisasi langkah ditunda karena pengguna belum masuk.');
      return;
    }

    _isFlushingDailySteps = true;
    try {
      await _dailyStepsRepository.upsertDailySteps(
        entries: cached,
        userId: userId,
      );
      await _discardSyncedDailySteps(cached.length);
      _log('Sinkronisasi ${cached.length} catatan langkah berhasil.');
    } catch (error, stackTrace) {
      _log('Gagal sinkronisasi data langkah: $error');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
    } finally {
      _isFlushingDailySteps = false;
    }
  }

  Future<void> _discardSyncedDailySteps(int count) async {
    if (count <= 0) return;

    final List<DailyStepEntry> current = _readCachedDailySteps();
    if (current.isEmpty) return;

    final int startIndex = count >= current.length ? current.length : count;
    if (startIndex == 0) return;

    final List<DailyStepEntry> remaining = current.sublist(startIndex);
    await _writeCachedDailySteps(remaining);
    _lastCachedStepValue = remaining.isNotEmpty ? remaining.last.step : _lastCachedStepValue;
    _persistLastStepValue(_lastCachedStepValue);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _sendVitalsRequest({bool force = false}) async {
    await _ensureTelemetryCharacteristics();

    final BluetoothCharacteristic? characteristic =
        _commandCharacteristic ?? _notifyCharacteristic;
    _log('Vitals request using characteristic: ${characteristic?.uuid}');
    if (characteristic == null) return;
    if (!isConnected.value) return;

    final CharacteristicProperties properties = characteristic.properties;
    final bool canWriteWithResponse = properties.write;
    final bool canWriteWithoutResponse = properties.writeWithoutResponse;
    if (!canWriteWithResponse && !canWriteWithoutResponse) {
      if (force) {
        lastError.value =
            'Karakteristik Bluetooth tidak mendukung permintaan data HR/SpO2.';
        _log('Tidak dapat mengirim permintaan HR/SpO2 (force).');
      }
      _log('Karakteristik tidak mendukung penulisan HR/SpO2.');
      return;
    }

    final DateTime now = DateTime.now();
    if (!force &&
        _lastVitalsRequestAt != null &&
        now.difference(_lastVitalsRequestAt!) < _vitalsRequestCooldown) {
      _log('Permintaan HR/SpO2 diabaikan (cooldown aktif).');
      return;
    }

    final List<int> payload = utf8.encode('y');
    final bool useWithoutResponse =
        !canWriteWithResponse && canWriteWithoutResponse;

    try {
      await characteristic.write(
        payload,
        withoutResponse: useWithoutResponse,
      );
      _lastVitalsRequestAt = now;
      _log(
        'Permintaan HR/SpO2 dikirim '
        '(tanpa response: $useWithoutResponse).',
      );
    } on FlutterBluePlusException catch (error) {
      if (force) {
        lastError.value =
            'Gagal meminta data HR/SpO2: ${error.description ?? error.code}';
      }
      _log('Gagal mengirim permintaan HR/SpO2: $error');
    } catch (error) {
      if (force) {
        lastError.value = 'Gagal meminta data HR/SpO2: $error';
      }
      _log('Gagal mengirim permintaan HR/SpO2: $error');
    }
  }

  void _showConnectionBanner() {
    _cancelConnectionBannerAutoHide();
    isConnectionBannerVisible.value = true;
  }

  void _scheduleConnectionBannerAutoHide({
    Duration delay = const Duration(seconds: 3),
  }) {
    _cancelConnectionBannerAutoHide();
    isConnectionBannerVisible.value = true;
    _bannerAutoHideTimer = Timer(delay, () {
      if (!isConnected.value && !isConnecting.value) {
        isConnectionBannerVisible.value = false;
      }
    });
  }

  void _cancelConnectionBannerAutoHide() {
    _bannerAutoHideTimer?.cancel();
    _bannerAutoHideTimer = null;
  }

  void _log(String message) {
    Get.log('[BluetoothController] $message');
  }

}

/// Lightweight snapshot of telemetry values for widgets that prefer
/// a single immutable object instead of multiple Rx values.
class HealthTelemetry {
  final int? steps;
  final int? heartRate;
  final int? spo2;
  final DateTime? lastUpdatedAt;

  const HealthTelemetry({
    required this.steps,
    required this.heartRate,
    required this.spo2,
    required this.lastUpdatedAt,
  });
}
