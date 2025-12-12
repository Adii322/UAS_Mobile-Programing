import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/data/models/user_model.dart';

class DailyTargetController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final targetController = TextEditingController();
  final RxBool isSaving = false.obs;

  final SupabaseClient _supabase = Supabase.instance.client;
  final UserController userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    final currentTarget = userController.user.value?.dailyTargetStep ?? 8000;
    targetController.text = currentTarget.toString();
  }

  @override
  void onClose() {
    targetController.dispose();
    super.onClose();
  }

  String? validateDailyTarget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Target harian tidak boleh kosong';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Target harian harus berupa angka';
    }
    if (parsed <= 0) {
      return 'Target harian harus lebih dari 0';
    }
    return null;
  }

  Future<void> updateDailyTarget() async {
    if (isSaving.value) return;
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final target = int.parse(targetController.text.trim());
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser == null) {
      Get.snackbar(
        'Gagal memperbarui',
        'Silakan login kembali.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'daily_target_step': target,
          },
        ),
      );

      final existingUser = userController.user.value;
      if (existingUser != null) {
        userController.setUser(
          UserModel(
            name: existingUser.name,
            birthday: existingUser.birthday,
            isMale: existingUser.isMale,
            weight: existingUser.weight,
            height: existingUser.height,
            job: existingUser.job,
            dailyTargetStep: target,
          ),
        );
      } else {
        await userController.loadCurrentUser();
      }

      Get.snackbar(
        'Target diperbarui',
        'Daily target berhasil disimpan.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      Get.snackbar(
        'Gagal memperbarui',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Gagal memperbarui',
        'Terjadi kesalahan tak terduga. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
