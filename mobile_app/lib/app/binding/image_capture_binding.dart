import 'package:get/get.dart';
import 'package:mobile_app/app/controller/image_capture_controller.dart';

class ImageCaptureBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageCaptureController>(() => ImageCaptureController());
  }
}