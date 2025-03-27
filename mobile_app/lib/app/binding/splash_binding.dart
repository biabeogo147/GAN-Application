import 'package:get/get.dart';
import 'package:mobile_app/app/controller/splash_controller.dart';

class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}
