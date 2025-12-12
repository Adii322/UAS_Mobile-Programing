import 'package:get/get.dart';
import 'package:young_care/app/modules/onboarding/controllers/splashscreen_controller.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashscreenController>(SplashscreenController());
  }
}
