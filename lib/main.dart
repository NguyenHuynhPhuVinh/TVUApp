import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Infrastructure
import 'infrastructure/network/api_service.dart';
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
import 'features/gamification/shop/shop_service.dart';

// Features - App
import 'features/app/routes/app_pages.dart';

// Core
import 'core/theme/app_theme.dart';

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

  // Other services
  await Get.putAsync(() => UpdateService().init());
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
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
