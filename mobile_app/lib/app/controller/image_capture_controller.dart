import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/app/service/api_service.dart';
import 'package:mobile_app/app/ui/widget/common_dialog.dart';

class ImageCaptureController extends GetxController {
  late BuildContext context;
  final ImagePicker _imagePicker = ImagePicker();
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  RxBool isCameraActive = false.obs;
  RxBool isLoading = false.obs;
  CameraController? cameraController;
  List<CameraDescription> cameras = [];

  // Mode can be 'detect' or 'generate'
  final String mode;

  // Constructor with optional mode parameter
  ImageCaptureController({this.mode = 'detect'});

  // Getter for screen title based on mode
  String get screenTitle => mode == 'detect'
      ? 'Detect Fake Image'
      : 'Generate Similar Image';

  // Getter for action button text
  String get actionButtonText => mode == 'detect'
      ? 'Detect Image'
      : 'Generate Image';

  // Initialize API service
  final ApiService _apiService = ApiService();

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

  // Modify analyzeImage to send image to API
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

    // Show loading indicator
    isLoading.value = true;

    try {
      // Process based on mode
      if (mode == 'detect') {
        // Logic for detecting fake images
        await Future.delayed(const Duration(seconds: 2)); // Placeholder
        CommonDialog.showSuccess(message: 'Image analyzed for authenticity');
      } else {
        // Logic for generating similar images
        await Future.delayed(const Duration(seconds: 2)); // Placeholder
        CommonDialog.showSuccess(message: 'Generated similar image successfully');
      }
      // Further processing would happen here
    } catch (e) {
      CommonDialog.showError(message: 'Error processing image: $e');
    } finally {
      isLoading.value = false;
    }
  }
}