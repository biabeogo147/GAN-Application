import 'package:get/get.dart';
import 'package:mobile_app/app/controller/main_controller.dart';

class MainBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(MainController());
  }
}
