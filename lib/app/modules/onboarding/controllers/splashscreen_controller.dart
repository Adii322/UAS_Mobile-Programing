import 'package:get/get.dart';
import 'package:young_care/app/routes/app_pages.dart';

class SplashscreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() async {
    Get.log("Navigate to OnBoarding");
    await Future.delayed(const Duration(seconds: 8));
    Get.offAllNamed(Routes.ONBOARDING);
  }
}
