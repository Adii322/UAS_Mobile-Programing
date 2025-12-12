import 'package:get/get.dart';
import 'package:young_care/app/common/controller/bluetooth_controller.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/data/repositories/pedometer_repository.dart';
import 'package:young_care/app/modules/pedometer/controllers/pedometer_run_controller.dart';

class PedometerRunBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PedometerRepository>()) {
      Get.lazyPut<PedometerRepository>(() => PedometerRepository());
    }
    Get.lazyPut<PedometerRunController>(
      () => PedometerRunController(
        pedometerRepository: Get.find<PedometerRepository>(),
        userController: Get.find<UserController>(),
        bluetoothController: Get.find<BluetoothController>(),
      ),
    );
  }
}
