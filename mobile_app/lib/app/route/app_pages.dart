import 'package:get/get.dart';
import 'package:mobile_app/app/binding/splash_binding.dart';
import 'package:mobile_app/app/ui/screen/splash_screen.dart';

class AppPages {
  static final args = Get.arguments as Map<String, dynamic>?;
  static final pages = [
    GetPage(
        name: AppRoute.splash_screen,
        page: () => const SplashScreen(),
        binding: SplashBinding()),
  ];
}

class AppRoute {
  static const String splash_screen = '/splash_screen';
}
