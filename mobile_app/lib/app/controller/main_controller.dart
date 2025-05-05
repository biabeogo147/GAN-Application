import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../ui/screen/image_capture.dart';
import 'image_capture_controller.dart';

class MainController extends GetxController {
  late BuildContext context;

  @override
  void onReady() async {
  }

  void onPressDetectFake() {
    print('onPressDetectFake');
  }

  void onPressGenerateImage() {
    print('onPressGenerateImage');
  }

  void onPressCaptureImage() {
    // Register the controller
    Get.lazyPut(() => ImageCaptureController());

    // Navigate to the screen
    Get.to(() => const ImageCaptureScreen());
  }
}
