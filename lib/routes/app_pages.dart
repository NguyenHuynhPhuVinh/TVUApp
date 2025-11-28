import 'package:get/get.dart';

// App features
import '../features/app/splash/bindings/splash_binding.dart';
import '../features/app/splash/views/splash_view.dart';
import '../features/app/home/home_binding.dart';
import '../features/app/home/views/home_view.dart';
import '../features/app/main/bindings/main_binding.dart';
import '../features/app/main/views/main_view.dart';

// Auth feature
import '../features/auth/bindings/auth_binding.dart';
import '../features/auth/views/login_view.dart';

// Academic features
import '../features/academic/curriculum/bindings/curriculum_binding.dart';
import '../features/academic/curriculum/views/curriculum_view.dart';
import '../features/academic/grades/bindings/grades_binding.dart';
import '../features/academic/grades/views/grades_view.dart';
import '../features/academic/schedule/bindings/schedule_binding.dart';
import '../features/academic/schedule/views/schedule_view.dart';
import '../features/academic/tuition/bindings/tuition_binding.dart';
import '../features/academic/tuition/views/tuition_view.dart';
import '../features/academic/tuition_bonus/bindings/tuition_bonus_binding.dart';
import '../features/academic/tuition_bonus/views/tuition_bonus_view.dart';

// Gamification features
import '../features/gamification/modules/game_setup/bindings/game_setup_binding.dart';
import '../features/gamification/modules/game_setup/views/game_setup_view.dart';
import '../features/gamification/modules/game_stats/bindings/game_stats_binding.dart';
import '../features/gamification/modules/game_stats/views/game_stats_view.dart';
import '../features/gamification/modules/game_rewards/bindings/game_rewards_binding.dart';
import '../features/gamification/modules/game_rewards/views/game_rewards_view.dart';
import '../features/gamification/modules/wallet/bindings/wallet_binding.dart';
import '../features/gamification/modules/wallet/views/wallet_view.dart';
import '../features/gamification/modules/shop/bindings/shop_binding.dart';
import '../features/gamification/modules/shop/views/shop_view.dart';

// User features
import '../features/user/news/bindings/news_binding.dart';
import '../features/user/news/views/news_view.dart';
import '../features/user/bindings/profile_binding.dart';
import '../features/user/views/profile_view.dart';

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
    GetPage(
      name: Routes.tuitionBonus,
      page: () => const TuitionBonusView(),
      binding: TuitionBonusBinding(),
    ),
    GetPage(
      name: Routes.wallet,
      page: () => const WalletView(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.shop,
      page: () => const ShopView(),
      binding: ShopBinding(),
    ),
  ];
}

