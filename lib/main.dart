import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Infrastructure
import 'infrastructure/network/api_service.dart';
import 'infrastructure/network/connectivity_service.dart';
import 'infrastructure/firebase/firebase_service.dart';
import 'infrastructure/storage/storage_service.dart';
import 'infrastructure/security/security_service.dart';
import 'infrastructure/update/update_service.dart';
import 'infrastructure/data_sync_manager.dart';

// Features - Auth
import 'features/auth/data/auth_service.dart';

// Features - Gamification
import 'features/gamification/core/game_service.dart';
import 'features/gamification/core/game_security_guard.dart';
import 'features/gamification/core/game_sync_service.dart';
import 'features/gamification/modules/shop/shop_service.dart';
import 'features/gamification/modules/mailbox/services/mailbox_service.dart';
import 'features/gamification/modules/reward_code/services/reward_code_service.dart';

// Features - Bug Report
import 'features/bug_report/services/bug_report_service.dart';

// Features - App
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await initServices();

  runApp(const TVUApp());
}

Future<void> initServices() async {
  // Connectivity service (init first to check network status)
  await Get.putAsync(() => ConnectivityService().init());

  // Core storage service
  await Get.putAsync(() => StorageService().init());

  // Auth & Firebase
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => FirebaseService().init());

  // Security services (must init before game services)
  await Get.putAsync(() => SecurityService().init());
  await Get.putAsync(() => GameSecurityGuard().init());
  await Get.putAsync(() => GameSyncService().init());

  // Game service (depends on security & sync)
  await Get.putAsync(() => GameService().init());

  // Shop service (depends on game & security)
  await Get.putAsync(() => ShopService().init());

  // Mailbox service (depends on game & storage)
  Get.put(MailboxService(), permanent: true);

  // Reward code service (depends on game & storage)
  Get.put(RewardCodeService(), permanent: true);

  // Other services
  await Get.putAsync(() => UpdateService().init());
  await Get.putAsync(() => BugReportService().init());
  Get.put(ApiService());

  // Data sync manager (depends on api, storage, firebase, game)
  await Get.putAsync(() => DataSyncManager().init());
}

class TVUApp extends StatelessWidget {
  const TVUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Cổng TVUApp',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
