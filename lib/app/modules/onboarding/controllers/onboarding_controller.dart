import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  final UserController userController = Get.find<UserController>();
  final RxBool isLoading = false.obs;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return;

    isLoading.value = true;
    await userController.loadCurrentUser();
    Get.offAllNamed(Routes.BASE);
  }

  void goToLogin() {
    if (isLoading.value) return;
    Get.offAndToNamed(Routes.LOGIN);
  }
}
