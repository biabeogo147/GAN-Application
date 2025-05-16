import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../ui/screen/image_capture_screen.dart';
import 'image_capture_controller.dart';

import '../ui/screen/face_generation_screen.dart';
import 'face_generation_controller.dart';

class MainController extends GetxController {
  late BuildContext context;

  @override
  void onReady() async {
  }

  void onPressDetectFake() {
    // Register the controller with "detect" mode
    Get.lazyPut(() => ImageCaptureController());

    // Navigate to the image capture screen
    Get.to(() => const ImageCaptureScreen());
  }

  void onPressGenerateImage() {
    // Register the new face generation controller
    Get.lazyPut(() => FaceGenerationController());

    // Navigate to the face generation screen
    Get.to(() => const FaceGenerationScreen());
  }
}
