import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/data/services/auth_service.dart';
import 'app/data/services/api_service.dart';
import 'app/data/services/firebase_service.dart';
import 'app/data/services/game_service.dart';
import 'app/data/services/local_storage_service.dart';
import 'app/data/services/update_service.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';

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
  await Get.putAsync(() => LocalStorageService().init());
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => FirebaseService().init());
  await Get.putAsync(() => GameService().init());
  await Get.putAsync(() => UpdateService().init());
  Get.put(ApiService());
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
