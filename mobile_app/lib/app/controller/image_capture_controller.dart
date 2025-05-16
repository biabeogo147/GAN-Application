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
    RxBool isFrontCamera = true.obs;
    RxBool isSwitchingCamera = false.obs;
    CameraController? cameraController;
    List<CameraDescription> cameras = [];

    // Initialize API service
    final ApiService _apiService = ApiService();

    // Results from the API
    Rx<Map<String, dynamic>> results = Rx<Map<String, dynamic>>({});

    // Constructor - no mode parameter needed anymore
    ImageCaptureController();

    // Fixed screen title for detection
    String get screenTitle => 'Detect Fake Image';

    // Fixed action button text
    String get actionButtonText => 'Detect Image';

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

      if (cameraController != null) {
        await cameraController!.dispose();
        cameraController = null;
      }

      await initializeCamera();
      isSwitchingCamera.value = false;

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
      } catch (e) {
        CommonDialog.showError(message: 'Failed to take picture: $e');
      }
    }

    void retakePhoto() {
      selectedImage.value = null;
      isReviewingImage.value = false;
    }

    // Updated for detection only
    void analyzeImage() async {
      if (selectedImage.value == null && !isCameraActive.value) {
        CommonDialog.showWarning(message: 'Please select an image or take a photo first');
        return;
      }

      if (isCameraActive.value) {
        isCameraActive.value = false;
        await cameraController!.dispose();
      }

      isReviewingImage.value = false;
      isLoading.value = true;

      try {
        // Always use 'detect' mode now
        final response = await _apiService.detectFakeImage(selectedImage.value!.path);

        results.value = response;

        if (response['success'] == true) {
          final resultsController = ResultsController(
            imageFile: File(selectedImage.value!.path),
            results: response,
            isDetectMode: true, // Always true since this is detection-only
          );

          Get.put<ResultsController>(resultsController);

          Get.to(
            () => const ResultsScreen(),
            binding: ResultsBinding(resultsController),
            routeName: '/results_screen'
          );
        } else {
          CommonDialog.showError(message: 'Failed to analyze image');
        }
      } catch (e) {
        CommonDialog.showError(message: 'Error analyzing image: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }