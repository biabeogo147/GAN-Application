import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/app/controller/results_controller.dart';
import 'package:mobile_app/app/service/api_service.dart';
import 'package:mobile_app/app/ui/widget/common_dialog.dart';

import '../binding/results_binding.dart';
import '../ui/screen/results_screen.dart';

class ImageCaptureController extends GetxController {
  late BuildContext context;
  final ImagePicker _imagePicker = ImagePicker();
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  RxBool isCameraActive = false.obs;
  RxBool isReviewingImage = false.obs;
  RxBool isLoading = false.obs;
  RxBool isFrontCamera = true.obs; // Default to front camera as current setup
  RxBool isSwitchingCamera = false.obs;
  CameraController? cameraController;
  List<CameraDescription> cameras = [];

  // Initialize API service
  final ApiService _apiService = ApiService();

  // Results from the API
  Rx<Map<String, dynamic>> results = Rx<Map<String, dynamic>>({});

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

  Future<void> initializeCamera() async {
    if (cameras.isEmpty) return;

    final cameraDescription = cameras.firstWhere(
          (camera) => camera.lensDirection ==
          (isFrontCamera.value ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => cameras[0],
    );

    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await cameraController!.initialize();
      if (!isCameraActive.value) {
        isCameraActive.value = true;
      }
      update(['cameraPreview']);
    } catch (e) {
      CommonDialog.showError(message: 'Failed to initialize camera: $e');
    }
  }

  Future<void> toggleCamera() async {
    if (cameras.length < 2) return;

    isSwitchingCamera.value = true;
    isFrontCamera.value = !isFrontCamera.value;

    // Recreate the camera controller with the new camera
    if (cameraController != null) {
      await cameraController!.dispose();
      cameraController = null;
    }

    await initializeCamera();
    isSwitchingCamera.value = false;

    // Force UI refresh
    update(['cameraPreview']);
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

    // Wait for camera initialization to complete before showing UI
    await initializeCamera();
    isCameraActive.value = true;
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

  void captureForReview() async {
    try {
      final XFile image = await cameraController!.takePicture();
      selectedImage.value = image;
      isReviewingImage.value = true;
      // Don't turn off camera yet
    } catch (e) {
      CommonDialog.showError(message: 'Failed to take picture: $e');
    }
  }

  void retakePhoto() {
    selectedImage.value = null;
    isReviewingImage.value = false;
  }

  // Modify analyzeImage to send image to API
  void analyzeImage() async {
    if (selectedImage.value == null && !isCameraActive.value) {
      CommonDialog.showWarning(message: 'Please select an image or take a photo first');
      return;
    }

    // If using camera, capture the image
    if (isCameraActive.value) {
      // final XFile image = await cameraController!.takePicture();
      // selectedImage.value = image;
      isCameraActive.value = false;
      await cameraController!.dispose();
    }

    isReviewingImage.value = false;

    // Show loading indicator
    isLoading.value = true;

    try {
      // Call the API service with the selected image path
      final response = await _apiService.uploadImage(selectedImage.value!.path, mode: mode);

      // Store the results
      results.value = response;

      // Process based on mode
      if (response['success'] == true) {
        // Create and register the results controller
        final resultsController = ResultsController(
          imageFile: File(selectedImage.value!.path),
          results: response,
          isDetectMode: mode == 'detect',
        );

        // Put the controller in GetX DI
        Get.put<ResultsController>(resultsController);

        // Navigate with proper binding
        Get.to(
                () => const ResultsScreen(),
            binding: ResultsBinding(resultsController),
            routeName: '/results_screen'  // Add route name for logging
        );

        print("Navigation to ResultsScreen attempted");
      } else {
        CommonDialog.showError(message: 'Failed to process image');
      }
    } catch (e) {
      CommonDialog.showError(message: 'Error processing image: $e');
    } finally {
      isLoading.value = false;
    }
  }
}