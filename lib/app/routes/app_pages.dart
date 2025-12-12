import 'package:get/get.dart';
import 'package:young_care/app/modules/onboarding/bindings/splash_screen_binding.dart';
import 'package:young_care/app/modules/onboarding/views/splash_screen_view.dart';

import '../modules/about_us/bindings/about_us_binding.dart';
import '../modules/about_us/views/about_us_view.dart';
import '../modules/activity/bindings/activity_binding.dart';
import '../modules/activity/views/activity_view.dart';
import '../modules/activity/views/activity_summary_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/base/bindings/base_binding.dart';
import '../modules/base/views/base_view.dart';
import '../modules/daily_target/bindings/daily_target_binding.dart';
import '../modules/daily_target/views/daily_target_view.dart';
import '../modules/data_history/bindings/data_history_binding.dart';
import '../modules/data_history/views/data_history_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/pedometer/bindings/pedometer_binding.dart';
import '../modules/pedometer/bindings/pedometer_run_binding.dart';
import '../modules/pedometer/views/pedometer_run_view.dart';
import '../modules/pedometer/views/pedometer_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.BASE,
      page: () => const BaseView(),
      binding: BaseBinding(),
      children: [
        GetPage(
          name: _Paths.HOME,
          page: () => const HomeView(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: _Paths.PROFILE,
          page: () => const ProfileView(),
          binding: ProfileBinding(),
        ),
        GetPage(
          name: _Paths.ACTIVITY,
          page: () => const ActivityView(),
          binding: ActivityBinding(),
        ),
        GetPage(
          name: _Paths.DAILY_TARGET,
          page: () => DailyTargetView(),
          binding: DailyTargetBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.PEDOMETER,
      page: () => const PedometerView(),
      binding: PedometerBinding(),
    ),
    GetPage(
      name: _Paths.PEDOMETER_RUN,
      page: () => const PedometerRunView(),
      binding: PedometerRunBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT_US,
      page: () => const AboutUsView(),
      binding: AboutUsBinding(),
    ),
    GetPage(
      name: _Paths.DATA_HISTORY,
      page: () => const DataHistoryView(),
      binding: DataHistoryBinding(),
    ),
    GetPage(
      name: _Paths.ACTIVITY_SUMMARY,
      page: () => const ActivitySummaryView(),
      binding: ActivityBinding(),
    ),
  ];

  static final mainChildren =
      routes.firstWhereOrNull((e) => e.name == _Paths.BASE)?.children ?? [];
}
