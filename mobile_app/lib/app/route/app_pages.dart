import 'package:get/get.dart';
import 'package:mobile_app/app/binding/splash_binding.dart';
import 'package:mobile_app/app/ui/screen/splash_screen.dart';

import 'package:mobile_app/app/binding/main_binding.dart';
import 'package:mobile_app/app/ui/screen/main_screen.dart';

class AppPages {
  static final args = Get.arguments as Map<String, dynamic>?;
  static final pages = [
    GetPage(
        name: AppRoute.splash_screen,
        page: () => const SplashScreen(),
        binding: SplashBinding()),
    GetPage(
        name: AppRoute.main_screen,
        page: () => MainScreen(),
        binding: MainBinding()),
  ];
}

class AppRoute {
  static const String splash_screen = '/splash_screen';
  static const String main_screen = '/main_screen';
}
