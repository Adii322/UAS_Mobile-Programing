import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GeoLocatorService {
  Future<Position> determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    var permissionStatus = await Permission.locationWhenInUse.status;
    if (permissionStatus.isDenied || permissionStatus.isRestricted) {
      permissionStatus = await Permission.locationWhenInUse.request();
    }

    if (permissionStatus.isPermanentlyDenied) {
      return Future.error(
        'Location permissions are permanently denied, please enable them from settings.',
      );
    }

    if (!permissionStatus.isGranted && !permissionStatus.isLimited) {
      return Future.error('Location permissions are denied');
    }

    final settingsFG = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      timeLimit: null,
    );

    return Geolocator.getCurrentPosition(
      locationSettings: settingsFG,
    );
  }

  /// Provides a continuous stream of high-accuracy position updates that can be
  /// used for tracking user movement during a run.
  Stream<Position> positionStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
      timeLimit: null,
    );

    return Geolocator.getPositionStream(locationSettings: settings);
  }
}
