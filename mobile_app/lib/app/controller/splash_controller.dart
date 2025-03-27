import 'dart:ui';
import 'package:get/get.dart';
import 'package:mobile_app/app/data/provider/local_storage.dart';

class SplashController extends GetxController {
  @override
  void onReady() async {
    super.onReady();
    String langString = await LocalStorage().getLanguageApp();
    if (langString == "") {
      langString = 'vi';
      LocalStorage().setLanguageApp('vi');
    }
    Get.updateLocale(langString == 'vi' ? const Locale('vi', 'VN') : const Locale('en', 'US'));
    await Future.delayed(const Duration(milliseconds: 2000));
  }
}
