import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/data/models/user_model.dart';
import 'package:young_care/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final isEditing = false.obs;

  final nameTextController = TextEditingController();
  final birthdayTextController = TextEditingController();
  final ageTextController = TextEditingController();
  final weightTextController = TextEditingController();
  final heightTextController = TextEditingController();
  final jobTextController = TextEditingController();

  final UserController userController = Get.find<UserController>();
  final RxBool isMale = true.obs;
  final SupabaseClient _supabase = Supabase.instance.client;
  final RxBool isLoggingOut = false.obs;

  late DateTime _selectedBirthday;
  Worker? _userWorker;

  DateTime get selectedBirthday => _selectedBirthday;

  @override
  void onInit() {
    final initialUser = userController.user.value;
    if (initialUser != null) {
      _populateFields(initialUser);
    } else {
      _selectedBirthday = DateTime.now();
    }
    _userWorker = ever<UserModel?>(userController.user, (user) {
      if (user != null) {
        _populateFields(user);
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    nameTextController.dispose();
    birthdayTextController.dispose();
    ageTextController.dispose();
    weightTextController.dispose();
    heightTextController.dispose();
    jobTextController.dispose();
    _userWorker?.dispose();
    super.onClose();
  }

  void enableEditing() {
    isEditing.value = true;
  }

  void cancelEditing() {
    final user = userController.user.value;
    if (user != null) {
      _populateFields(user);
    }
    isEditing.value = false;
  }

  Future<void> pickBirthday(BuildContext context) async {
    if (!isEditing.value) return;
    final initialDate = _selectedBirthday;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _selectedBirthday = picked;
      birthdayTextController.text = _formatDate(picked);
      ageTextController.text = _calculateAge(picked).toString();
    }
  }

  Future<void> saveProfile() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Tidak dapat menyimpan',
        'Silakan login kembali.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final birthday = _selectedBirthday;
    final weight = double.parse(weightTextController.text.trim());
    final height = double.parse(heightTextController.text.trim());
    final job = jobTextController.text.trim();
    final existingDailyTarget =
        userController.user.value?.dailyTargetStep ?? 8000;

    final updatedUser = UserModel(
      name: nameTextController.text.trim(),
      birthday: birthday,
      isMale: isMale.value,
      weight: weight,
      height: height,
      job: job.isEmpty ? null : job,
      dailyTargetStep: existingDailyTarget,
    );

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': updatedUser.name,
            'birthday': updatedUser.birthday.toIso8601String(),
            'is_male': updatedUser.isMale,
            'weight': updatedUser.weight,
            'height': updatedUser.height,
            'job': updatedUser.job,
            'daily_target_step': updatedUser.dailyTargetStep,
          },
        ),
      );

      userController.setUser(updatedUser);
      Get.snackbar(
        'Profil tersimpan',
        'Data kamu berhasil diperbarui.',
        snackPosition: SnackPosition.BOTTOM,
      );
      isEditing.value = false;
    } on AuthException catch (e) {
      Get.snackbar(
        'Gagal menyimpan',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Gagal menyimpan',
        'Terjadi kesalahan tak terduga. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

  }

  void showSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pengaturan',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: isLoggingOut.value ? null : logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFF03624C),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: isLoggingOut.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      isLoggingOut.value ? 'Logout...' : 'Logout',
                      style: GoogleFonts.lexendDeca(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    final isOpen = Get.isBottomSheetOpen;
                    if (isOpen != null && isOpen) {
                      Get.back<void>();
                    }
                    Get.toNamed(Routes.ABOUT_US);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.info_outline),
                  label: Text(
                    'About Us',
                    style: GoogleFonts.lexendDeca(
                      fontWeight: FontWeight.w600,
                      color: Color(0XFF03624C)
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    if (Get.isBottomSheetOpen ?? false) {
      Get.back<void>();
    }
    isLoggingOut.value = true;
    try {
      await _supabase.auth.signOut();
      userController.clearUser();
      Get.offAllNamed(Routes.ONBOARDING);
    } on AuthException catch (e) {
      Get.snackbar(
        'Gagal logout',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Gagal logout',
        'Terjadi kesalahan tak terduga. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoggingOut.value = false;
    }
  }

  void _populateFields(UserModel user) {
    nameTextController.text = user.name;
    _selectedBirthday = user.birthday;
    birthdayTextController.text = _formatDate(user.birthday);
    ageTextController.text = _calculateAge(user.birthday).toString();
    isMale.value = user.isMale;
    weightTextController.text = user.weight.toString();
    heightTextController.text = user.height.toString();
    jobTextController.text = user.job ?? '';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  int _calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }
}
