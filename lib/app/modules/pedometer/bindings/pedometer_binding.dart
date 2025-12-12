import 'package:get/get.dart';
import 'package:young_care/app/data/repositories/pedometer_repository.dart';

import '../controllers/pedometer_controller.dart';

class PedometerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PedometerRepository>()) {
      Get.lazyPut<PedometerRepository>(() => PedometerRepository());
    }
    Get.lazyPut<PedometerController>(
      () => PedometerController(),
    );
  }
}
