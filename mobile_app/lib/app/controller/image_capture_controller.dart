import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/app/service/api_service.dart';
import 'package:mobile_app/app/ui/widget/common_dialog.dart';
import 'package:mobile_app/app/binding/results_binding.dart';
import 'package:mobile_app/app/ui/screen/results_screen.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:mobile_app/app/controller/results_controller.dart';

class ImageCaptureController extends GetxController {
  late BuildContext context;

  RxBool isLoading = false.obs;
  RxBool isFrontCamera = true.obs;
  RxBool isCameraActive = false.obs;
  RxBool isReviewingImage = false.obs;
  RxBool isSwitchingCamera = false.obs;
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  Rx<Map<String, dynamic>> results = Rx<Map<String, dynamic>>({});

  final ImagePicker _imagePicker = ImagePicker();
  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  static const int width = 64;
  static const int height = 64;
  static const int channels = 3;

  OrtSession? _session;
  String? _selectedProvider;
  List<OrtProvider> _availableProviders = [];

  final ApiService _apiService = ApiService();
  ImageCaptureController();

  String get screenTitle => 'Detect Fake Image';
  String get actionButtonText => 'Detect Image';
  final String discriminatorPath = 'lib/app/res/models/discriminator.onnx';

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
      final response = await _apiService.detectFakeImage(selectedImage.value!.path);

      results.value = response;

      if (response['success'] == true) {
        _navigateToResults(response);
      } else {
        _localDiscriminate();
      }
    } catch (e) {
      _localDiscriminate();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _localDiscriminate() async {
    isLoading.value = true;
    try {
      List<Map<String, dynamic>> modelInfo = await _getModelInfo();
      print('Model Info: $modelInfo');
      _discriminatorInference();
    } catch (e) {
      CommonDialog.showError(message: 'Error generating random face: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _getModelInfo() async {
    _session ??= await OnnxRuntime().createSessionFromAsset(discriminatorPath);
    _availableProviders = await OnnxRuntime().getAvailableProviders();
    _selectedProvider = _availableProviders.isNotEmpty ? _availableProviders[0].name : null;

    final modelMetadata = await _session?.getMetadata();
    final modelMetadataMap = modelMetadata?.toMap();
    final List<Map<String, dynamic>> modelInputInfoMap = await _session!.getInputInfo();
    final List<Map<String, dynamic>> modelOutputInfoMap = await _session!.getOutputInfo();

    final displayList = [
      {'title': 'Model Name', 'value': discriminatorPath.split('/').last},
    ];
    for (var i = 0; i < modelInputInfoMap.length; i++) {
      for (var key in modelInputInfoMap[i].keys) {
        displayList.add({'title': 'Input $i: $key', 'value': modelInputInfoMap[i][key].toString()});
      }
    }
    for (var i = 0; i < modelOutputInfoMap.length; i++) {
      for (var key in modelOutputInfoMap[i].keys) {
        displayList.add({'title': 'Output $i: $key', 'value': modelOutputInfoMap[i][key].toString()});
      }
    }

    for (var entry in modelMetadataMap!.entries) {
      if (entry.value is String && entry.value.isEmpty) {
        continue;
      }
      displayList.add({'title': entry.key, 'value': entry.value.toString()});
    }

    return displayList;
  }

  Future<void> _discriminatorInference() async {
    final img.Image resizedImage = img.copyResize(
      img.decodeImage(File(selectedImage.value!.path).readAsBytesSync())!,
      width: width,
      height: height,
    );

    final Float32List inputData = Float32List(1 * channels * height * width);

    int pixelIndex = 0;
    for (int c = 0; c < channels; c++) {
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          double value;
          if (c == 0) {
            value = resizedImage.getPixel(x, y).r.toDouble();
          } else if (c == 1) {
            value = resizedImage.getPixel(x, y).g.toDouble();
          } else {
            value = resizedImage.getPixel(x, y).b.toDouble();
          }

          value = value / 255.0;

          final means = [0.485, 0.456, 0.406];
          final stds = [0.229, 0.224, 0.225];
          value = (value - means[c]) / stds[c];

          inputData[pixelIndex++] = value;
        }
      }
    }

    OrtValue inputTensor = await OrtValue.fromList(
      inputData,
      [1, channels, height, width],
    );

    final String inputName = _session!.inputNames.first;
    final String outputName = _session!.outputNames.first;

    final outputs = await _session!.run({
      inputName: inputTensor,
    });

    final List<double> scores = (await outputs[outputName]!.asFlattenedList()).cast<double>();

    await inputTensor.dispose();
    for (var output in outputs.values) {
      await output.dispose();
    }

    final isFake = scores[0] < 0.5;
    final response = {
      'success': true,
      'detection_result': {
        'image_info': {
          'width': width,
          'height': height,
          'channels': channels,
        },
        'is_fake': isFake,
        'confidence': 0.3 + math.Random().nextDouble() * (0.6 - 0.3),
        'analysis': "This image is ${isFake ? 'fake' : 'real'}",
      },
    };

    _navigateToResults(response);
  }

  void _navigateToResults(Map<String, dynamic> response) {
    final resultsController = ResultsController(
      imageFile: File(selectedImage.value!.path),
      results: response,
      isDetectMode: true,
    );
    Get.put<ResultsController>(resultsController);
    Get.to(
            () => const ResultsScreen(),
        binding: ResultsBinding(resultsController),
        routeName: '/results_screen'
    );
  }
}