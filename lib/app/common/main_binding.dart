import 'package:get/get.dart';
import 'package:young_care/app/common/controller/bluetooth_controller.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/core/services/geolocator_service.dart';

class MainBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    Get.lazyPut<GeoLocatorService>(() => GeoLocatorService(), fenix: true);
    Get.put<UserController>(UserController(), permanent: true);
    Get.put<BluetoothController>(BluetoothController(), permanent: true);
  }
}
