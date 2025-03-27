import 'package:get/get.dart';
import 'package:mobile_app/app/controller/app_controller.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AppController());
  }
}
