import 'dart:ui';
import 'package:get/get.dart';
import 'package:mobile_app/app/route/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onReady() async {
    super.onReady();
    String langString = "en";
    Get.updateLocale(langString == 'vi' ? const Locale('vi', 'VN') : const Locale('en', 'US'));
    await Future.delayed(const Duration(milliseconds: 2000));
    Get.offNamed(AppRoute.main_screen);
  }
}
