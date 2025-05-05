import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/app/ui/widget/common_dialog.dart';

class ImageCaptureController extends GetxController {
  late BuildContext context;
  final ImagePicker _imagePicker = ImagePicker();
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  RxBool isCameraActive = false.obs;
  CameraController? cameraController;
  List<CameraDescription> cameras = [];

  @override
  void onInit() {
    super.onInit();
    _initCameras();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  Future<void> _initCameras() async {
    try {
      cameras = await availableCameras();
    } catch (e) {
      print('Failed to get available cameras: $e');
    }
  }

  void captureImage() async {
    if (cameras.isEmpty) {
      await _initCameras();
      if (cameras.isEmpty) {
        CommonDialog.showError(message: 'No camera available');
        return;
      }
    }

    selectedImage.value = null;

    cameraController = CameraController(
      // Use front camera for face detection
      cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras[0],
      ),
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await cameraController!.initialize();
      isCameraActive.value = true;
    } catch (e) {
      CommonDialog.showError(message: 'Failed to initialize camera: $e');
    }
  }

  void pickImageFromGallery() async {
    isCameraActive.value = false;
    if (cameraController != null) {
      await cameraController!.dispose();
    }

    final XFile? pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      selectedImage.value = pickedImage;
    }
  }

  void analyzeImage() async {
    if (selectedImage.value == null && !isCameraActive.value) {
      CommonDialog.showWarning(message: 'Please select an image or take a photo first');
      return;
    }

    // If using camera, capture the image
    if (isCameraActive.value) {
      try {
        final XFile image = await cameraController!.takePicture();
        selectedImage.value = image;
        isCameraActive.value = false;
        await cameraController!.dispose();
      } catch (e) {
        CommonDialog.showError(message: 'Failed to take picture: $e');
        return;
      }
    }

    // Call your face detection logic here
    // For example: Get.find<FakeDetectionController>().analyzeImage(selectedImage.value!.path);

    // For now, just show a success message
    CommonDialog.showSuccess(message: 'Image captured successfully and ready for analysis');
  }
}