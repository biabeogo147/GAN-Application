import 'package:get/get.dart';
import 'package:mobile_app/app/controller/face_generation_controller.dart';

class FaceGenerationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FaceGenerationController());
  }
}