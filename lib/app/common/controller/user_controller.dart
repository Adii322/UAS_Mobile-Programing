import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:young_care/app/data/models/user_model.dart';

class UserController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Rxn<UserModel> user = Rxn<UserModel>();

  Future<void> loadCurrentUser() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      user.value = null;
      return;
    }

    final mappedUser = _mapFromSupabaseUser(currentUser);
    if (mappedUser != null) {
      user.value = mappedUser;
    }
  }

  void setUser(UserModel newUser) {
    user.value = newUser;
  }

  void clearUser() {
    user.value = null;
  }

  String? get userId => _supabase.auth.currentUser?.id;

  UserModel? _mapFromSupabaseUser(User supabaseUser) {
    final metadata = supabaseUser.userMetadata ?? {};

    final rawBirthday = metadata['birthday'];
    DateTime? birthday;
    if (rawBirthday is String) {
      birthday = DateTime.tryParse(rawBirthday);
    } else if (rawBirthday is DateTime) {
      birthday = rawBirthday;
    }
    birthday ??= DateTime.now();

    final name =
        (metadata['full_name'] ?? supabaseUser.email ?? 'User').toString();
    final job = metadata['job']?.toString();
    final isMale = _parseBool(metadata['is_male']) ?? true;
    final height = _parseDouble(metadata['height']) ?? 0;
    final weight = _parseDouble(metadata['weight']) ?? 0;
    final dailyTargetStep = _parseInt(metadata['daily_target_step']) ?? 8000;

    return UserModel(
      name: name,
      birthday: birthday,
      isMale: isMale,
      weight: weight,
      height: height,
      job: job?.isEmpty == true ? null : job,
      dailyTargetStep: dailyTargetStep,
    );
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'male') return true;
      if (lower == 'false' || lower == '0' || lower == 'female') return false;
    }
    if (value is num) return value != 0;
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
