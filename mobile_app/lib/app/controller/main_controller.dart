import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../ui/screen/image_capture_screen.dart';
import 'image_capture_controller.dart';

class MainController extends GetxController {
  late BuildContext context;

  @override
  void onReady() async {
  }

  void onPressDetectFake() {
    // Register the controller with "detect" mode
    Get.lazyPut(() => ImageCaptureController(mode: 'detect'));

    // Navigate to the image capture screen
    Get.to(() => const ImageCaptureScreen());
  }

  void onPressGenerateImage() {
    // Register the controller with "generate" mode
    Get.lazyPut(() => ImageCaptureController(mode: 'generate'));

    // Navigate to the image capture screen
    Get.to(() => const ImageCaptureScreen());
  }
}
