import 'package:get/get.dart';
import 'package:young_care/app/data/repositories/pedometer_repository.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PedometerRepository>()) {
      Get.lazyPut<PedometerRepository>(() => PedometerRepository());
    }
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
