import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/data/models/user_model.dart';
import 'package:young_care/app/routes/app_pages.dart';

class AuthController extends GetxController {
  final RxBool isLoginLoading = false.obs;
  final RxBool isRegisterLoading = false.obs;
  final RxBool isObscured = true.obs;
  final UserController userController = Get.find<UserController>();
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final registerFormKey = GlobalKey<FormState>();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final jobController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final birthdayController = TextEditingController();
  final Rxn<DateTime> selectedBirthday = Rxn<DateTime>();
  final Rxn<String> selectedGender = Rxn<String>();

  final SupabaseClient _supabase = Supabase.instance.client;

  void toggleObscured() {
    isObscured.value = !isObscured.value;
  }

  Future<void> pickBirthday(BuildContext context) async {
    final initialDate = selectedBirthday.value ?? DateTime.now();
    final firstDate = DateTime(DateTime.now().year - 100);
    final lastDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      selectedBirthday.value = picked;
      birthdayController.text = _formatDate(picked);
    }
  }

  Future<void> login() async {
    if (isLoginLoading.value) return;
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;

    Get.focusScope?.unfocus();

    isLoginLoading.value = true;
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.session == null || response.user == null) {
        Get.snackbar(
          'Login gagal',
          'Tidak dapat masuk. Silakan coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await userController.loadCurrentUser();
      Get.offAllNamed(Routes.BASE);
    } on AuthException catch (e) {
      Get.snackbar(
        'Login gagal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Login gagal',
        'Terjadi kesalahan tak terduga. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> register() async {
    if (isRegisterLoading.value) return;
    final formState = registerFormKey.currentState;
    if (formState == null || !formState.validate()) return;

    Get.focusScope?.unfocus();

    final height = double.tryParse(heightController.text.trim());
    final weight = double.tryParse(weightController.text.trim());

    if (selectedBirthday.value == null) {
      Get.snackbar(
        'Data tidak lengkap',
        'Tanggal lahir harus dipilih.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedGender.value == null) {
      Get.snackbar(
        'Data tidak lengkap',
        'Gender harus dipilih.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (height == null || height <= 0 || weight == null || weight <= 0) {
      Get.snackbar(
        'Data tidak valid',
        'Berat dan tinggi badan harus berupa angka lebih dari 0.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isRegisterLoading.value = true;
    try {
      final trimmedJob = jobController.text.trim();
      final birthday = selectedBirthday.value!;
      final isMale = selectedGender.value == 'male';
      final newUser = UserModel(
        name: fullNameController.text.trim(),
        birthday: birthday,
        isMale: isMale,
        weight: weight,
        height: height,
        job: trimmedJob.isEmpty ? null : trimmedJob,
        dailyTargetStep: 8000,
      );

      final response = await _supabase.auth.signUp(
        email: registerEmailController.text.trim(),
        password: registerPasswordController.text,
        data: {
          'full_name': newUser.name,
          'job': trimmedJob,
          'birthday': birthday.toIso8601String(),
          'height': height,
          'weight': weight,
          'is_male': isMale,
          'daily_target_step': newUser.dailyTargetStep,
        },
      );

      if (response.user == null) {
        Get.snackbar(
          'Registrasi gagal',
          'Tidak dapat membuat akun. Silakan coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      userController.setUser(newUser);
      if (_supabase.auth.currentUser != null) {
        await userController.loadCurrentUser();
      }
      _clearRegisterForm();
      Get.offAllNamed(Routes.BASE);
    } on AuthException catch (e) {
      Get.snackbar(
        'Registrasi gagal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Registrasi gagal',
        'Terjadi kesalahan tak terduga. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRegisterLoading.value = false;
    }
  }

  void _clearRegisterForm() {
    registerFormKey.currentState?.reset();
    registerEmailController.clear();
    registerPasswordController.clear();
    fullNameController.clear();
    jobController.clear();
    heightController.clear();
    weightController.clear();
    birthdayController.clear();
    selectedBirthday.value = null;
    selectedGender.value = null;
  }

  String _formatDate(DateTime date) {
    final twoDigits = (int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
  }
}
