import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

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
}
