import 'package:get/get.dart';
import 'package:young_care/app/data/repositories/pedometer_repository.dart';

import '../controllers/activity_controller.dart';

class ActivityBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PedometerRepository>()) {
      Get.lazyPut<PedometerRepository>(() => PedometerRepository());
    }
    if (!Get.isRegistered<ActivityController>()) {
      Get.lazyPut<ActivityController>(() => ActivityController());
    }
  }
}
