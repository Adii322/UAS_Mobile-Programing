import 'package:get/get.dart';

import '../controllers/daily_target_controller.dart';

class DailyTargetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyTargetController>(
      () => DailyTargetController(),
    );
  }
}
