import 'package:get/get.dart';
import 'package:mobile_app/app/controller/app_controller.dart';
import 'package:mobile_app/app/controller/image_capture_controller.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AppController());
  }
}

class AppBindings implements Bindings {
  @override
  void dependencies() {
    // Register your controllers here
    Get.lazyPut<ImageCaptureController>(() => ImageCaptureController());
  }
}
