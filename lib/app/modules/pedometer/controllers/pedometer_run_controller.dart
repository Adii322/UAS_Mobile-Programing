import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:young_care/app/common/controller/bluetooth_controller.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/core/services/geolocator_service.dart';
import 'package:young_care/app/data/models/pedometer_result.dart';
import 'package:young_care/app/data/repositories/pedometer_repository.dart';

enum RunStatus { idle, running, paused }

class RunSummary {
  RunSummary({
    required this.elapsed,
    required this.distanceMeters,
    required this.route,
  });

  final Duration elapsed;
  final double distanceMeters;
  final List<LatLng> route;
}

class PedometerRunController extends GetxController {
  PedometerRunController({
    GeoLocatorService? geoLocatorService,
    PedometerRepository? pedometerRepository,
    UserController? userController,
    BluetoothController? bluetoothController,
  })  : geoLocatorService =
            geoLocatorService ?? Get.find<GeoLocatorService>(),
        _pedometerRepository =
            pedometerRepository ?? Get.find<PedometerRepository>(),
        _userController = userController ?? Get.find<UserController>(),
        _bluetoothController =
            bluetoothController ?? Get.find<BluetoothController>();

  final GeoLocatorService geoLocatorService;
  final PedometerRepository _pedometerRepository;
  final UserController _userController;
  final BluetoothController _bluetoothController;

  final Rx<bool> isLoadingPosition = false.obs;
  final Rxn<Position> currentPosition = Rxn<Position>();
  final Rx<RunStatus> runStatus = RunStatus.idle.obs;
  final RxInt elapsedSeconds = 0.obs;
  final RxDouble distanceMeters = 0.0.obs;
  final RxDouble paceMinutesPerKilometer = 0.0.obs;
  final RxList<LatLng> recordedPositions = <LatLng>[].obs;
  final Rxn<RunSummary> completedRun = Rxn<RunSummary>();
  final RxBool isSavingRun = false.obs;

  Position? _initialPosition;
  Position? _lastPosition;
  Position? _lastRecordedPosition;
  DateTime? _lastRecordedTime;
  Timer? _ticker;
  StreamSubscription<Position>? _positionSubscription;

  Duration _elapsed = Duration.zero;
  DateTime? _segmentStart;

  bool get hasActiveRun => runStatus.value == RunStatus.running;

  Future<void> getInitPosition() async {
    isLoadingPosition.value = true;
    try {
      _initialPosition = await geoLocatorService.determinePosition();
      currentPosition.value = _initialPosition;
      await _subscribeToPositionStream();
    } catch (error) {
      // Optionally handle the error (e.g. show a snackbar) in the UI layer.
    } finally {
      isLoadingPosition.value = false;
    }
  }

  void startRun() {
    if (runStatus.value == RunStatus.running) {
      return;
    }

    if (runStatus.value == RunStatus.idle) {
      completedRun.value = null;
      _resetRunData();
      _seedInitialRoutePoint();
    }

    runStatus.value = RunStatus.running;
    _startTiming();
  }

  void pauseRun() {
    if (runStatus.value != RunStatus.running) {
      return;
    }
    _stopTiming();
    runStatus.value = RunStatus.paused;
  }

  void resumeRun() {
    if (runStatus.value != RunStatus.paused) {
      return;
    }
    runStatus.value = RunStatus.running;
    _startTiming();
  }

  RunSummary finishRun() {
    if (runStatus.value == RunStatus.idle && elapsedSeconds.value == 0) {
      return RunSummary(
        elapsed: Duration.zero,
        distanceMeters: 0.0,
        route: const <LatLng>[],
      );
    }

    _stopTiming();
    runStatus.value = RunStatus.idle;

    final summary = RunSummary(
      elapsed: _effectiveElapsed,
      distanceMeters: distanceMeters.value,
      route: List<LatLng>.from(recordedPositions),
    );

    completedRun.value = summary;
    _resetRunData();
    return summary;
  }

  Future<RunSummary> finishRunAndPersist() async {
    if (isSavingRun.value) {
      throw Exception('Sesi lari sebelumnya masih dalam proses penyimpanan.');
    }

    final String? userId = _userController.userId;
    if (userId == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    isSavingRun.value = true;
    try {
      final RunSummary summary = finishRun();

      const int maxAttempts = 3;
      const Duration vitalWaitDuration = Duration(seconds: 23);
      int? heartRate;
      int? oxygenUnit;

      for (int attempt = 0;
          attempt < maxAttempts &&
              (heartRate == null || oxygenUnit == null);
          attempt++) {
        final HealthTelemetry? telemetry =
            await _bluetoothController.requestVitalSignsSnapshot(
          timeout: vitalWaitDuration,
          minWait: vitalWaitDuration,
        );

        heartRate ??=
            telemetry?.heartRate ?? _bluetoothController.heartRate.value;
        oxygenUnit ??=
            telemetry?.spo2 ?? _bluetoothController.spo2.value;
      }

      final DateTime createdAt = DateTime.now();

      final PedometerResult baseResult = PedometerResult(
        userId: userId,
        createdAt: createdAt,
        positions: summary.route,
        heartRate: heartRate,
        oxygenUnit: oxygenUnit,
        totalSeconds: summary.elapsed.inSeconds,
      );

      await _pedometerRepository.insertResult(baseResult);
      return summary;
    } finally {
      isSavingRun.value = false;
    }
  }

  String get formattedElapsed {
    final duration = Duration(seconds: elapsedSeconds.value);
    return formatDuration(duration);
  }

  String formatDuration(Duration duration) {
    final twoDigits = (int value) => value.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  String get distanceInKilometers =>
      formatDistanceMeters(distanceMeters.value);

  String formatDistanceMeters(double meters) =>
      (meters / 1000).toStringAsFixed(2);

  String get paceLabel {
    final paceValue = paceMinutesPerKilometer.value;
    if (paceValue.isInfinite ||
        paceValue.isNaN ||
        paceValue == 0 ||
        distanceMeters.value <= 0) {
      return '00:00';
    }

    final totalSeconds = (paceValue * 60).round();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void onInit() {
    super.onInit();
    getInitPosition();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    _positionSubscription?.cancel();
    super.onClose();
  }

  Future<void> _subscribeToPositionStream() async {
    await _positionSubscription?.cancel();
    _positionSubscription = geoLocatorService.positionStream().listen(
      (position) {
        currentPosition.value = position;
        if (runStatus.value == RunStatus.running) {
          _processActiveRunPosition(position);
        } else {
          _lastPosition = position;
        }
      },
    );
  }

  void _processActiveRunPosition(Position newPosition) {
    if (_lastPosition == null) {
      _lastPosition = newPosition;
      return;
    }

    final distanceDelta = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    if (distanceDelta > 0) {
      distanceMeters.value += distanceDelta;
      _recalculatePace();
      _maybeRecordRoutePoint(newPosition);
    }

    _lastPosition = newPosition;
  }

  void _maybeRecordRoutePoint(Position newPosition) {
    final now = DateTime.now();

    if (_lastRecordedPosition == null) {
      recordedPositions.add(LatLng(newPosition.latitude, newPosition.longitude));
      _lastRecordedPosition = newPosition;
      _lastRecordedTime = now;
      return;
    }

    final elapsedSinceLastRecord =
        now.difference(_lastRecordedTime ?? now).inSeconds;
    final distanceSinceLastRecord = Geolocator.distanceBetween(
      _lastRecordedPosition!.latitude,
      _lastRecordedPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    if (distanceSinceLastRecord >= 15 && elapsedSinceLastRecord >= 5) {
      recordedPositions.add(
        LatLng(newPosition.latitude, newPosition.longitude),
      );
      _lastRecordedPosition = newPosition;
      _lastRecordedTime = now;
    }
  }

  void _startTiming() {
    _segmentStart ??= DateTime.now();
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value = _effectiveElapsed.inSeconds;
      _recalculatePace();
    });
  }

  void _stopTiming() {
    if (_segmentStart != null) {
      _elapsed += DateTime.now().difference(_segmentStart!);
      _segmentStart = null;
    }

    _ticker?.cancel();
    _ticker = null;
    elapsedSeconds.value = _effectiveElapsed.inSeconds;
    _recalculatePace();
  }

  void _recalculatePace() {
    final elapsedMinutes = _effectiveElapsed.inSeconds / 60;
    final distanceKm = distanceMeters.value / 1000;
    if (distanceKm <= 0 || elapsedMinutes <= 0) {
      paceMinutesPerKilometer.value = 0;
      return;
    }
    paceMinutesPerKilometer.value = elapsedMinutes / distanceKm;
  }

  Duration get _effectiveElapsed {
    if (_segmentStart != null) {
      return _elapsed + DateTime.now().difference(_segmentStart!);
    }
    return _elapsed;
  }

  void _resetRunData() {
    _elapsed = Duration.zero;
    _segmentStart = null;
    elapsedSeconds.value = 0;
    distanceMeters.value = 0;
    paceMinutesPerKilometer.value = 0;
    recordedPositions.clear();
    _lastPosition = currentPosition.value;
    _lastRecordedPosition = null;
    _lastRecordedTime = null;
  }

  void _seedInitialRoutePoint() {
    final position = currentPosition.value ?? _initialPosition;
    if (position != null) {
      recordedPositions.add(LatLng(position.latitude, position.longitude));
      _lastRecordedPosition = position;
      _lastRecordedTime = DateTime.now();
      _lastPosition = position;
    }
  }

  Position? get initialPosition => _initialPosition;
}
