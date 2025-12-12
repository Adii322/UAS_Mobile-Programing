import 'package:get/get.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/data/repositories/pedometer_repository.dart';

import '../controllers/data_history_controller.dart';

class DataHistoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PedometerRepository>()) {
      Get.lazyPut<PedometerRepository>(() => PedometerRepository());
    }
    Get.lazyPut<DataHistoryController>(
      () => DataHistoryController(
        pedometerRepository: Get.find<PedometerRepository>(),
        userController: Get.find<UserController>(),
      ),
    );
  }
}
