import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/curriculum/bindings/curriculum_binding.dart';
import '../modules/curriculum/views/curriculum_view.dart';
import '../modules/game_setup/bindings/game_setup_binding.dart';
import '../modules/game_setup/views/game_setup_view.dart';
import '../modules/game_stats/bindings/game_stats_binding.dart';
import '../modules/game_stats/views/game_stats_view.dart';
import '../modules/game_rewards/bindings/game_rewards_binding.dart';
import '../modules/game_rewards/views/game_rewards_view.dart';
import '../modules/grades/bindings/grades_binding.dart';
import '../modules/grades/views/grades_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/news/bindings/news_binding.dart';
import '../modules/news/views/news_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/schedule/bindings/schedule_binding.dart';
import '../modules/schedule/views/schedule_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/tuition/bindings/tuition_binding.dart';
import '../modules/tuition/views/tuition_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.schedule,
      page: () => const ScheduleView(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: Routes.grades,
      page: () => const GradesView(),
      binding: GradesBinding(),
    ),
    GetPage(
      name: Routes.tuition,
      page: () => const TuitionView(),
      binding: TuitionBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.curriculum,
      page: () => const CurriculumView(),
      binding: CurriculumBinding(),
    ),
    GetPage(
      name: Routes.news,
      page: () => const NewsView(),
      binding: NewsBinding(),
    ),
    GetPage(
      name: Routes.gameSetup,
      page: () => const GameSetupView(),
      binding: GameSetupBinding(),
    ),
    GetPage(
      name: Routes.gameStats,
      page: () => const GameStatsView(),
      binding: GameStatsBinding(),
    ),
    GetPage(
      name: Routes.gameRewards,
      page: () => const GameRewardsView(),
      binding: GameRewardsBinding(),
    ),
  ];
}
