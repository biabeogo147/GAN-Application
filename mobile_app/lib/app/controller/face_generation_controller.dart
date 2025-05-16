import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mobile_app/app/service/api_service.dart';
import 'package:mobile_app/app/ui/screen/results_screen.dart';
import 'package:mobile_app/app/ui/widget/common_dialog.dart';
import 'package:mobile_app/app/controller/results_controller.dart';

import '../binding/results_binding.dart';

class FaceGenerationController extends GetxController {
  final ApiService _apiService = ApiService();

  RxBool isLoading = false.obs;
  RxString generatedImagePath = ''.obs;
  RxMap<String, dynamic> results = <String, dynamic>{}.obs;

  final TextEditingController descriptionController = TextEditingController();

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> generateRandomFace() async {
    isLoading.value = true;

    try {
      final response = await _apiService.generateRandomFace();

      if (response['success'] == true && response['generated_image'] != null) {
        final imagePath = await _saveBase64Image(response['generated_image']['image']);
        generatedImagePath.value = imagePath;

        results.value = response;

        _navigateToResults(imagePath, response);
      } else {
        await _localGenerateRandomFace();
      }
    } catch (e) {
      await _localGenerateRandomFace();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateFaceFromText() async {
    if (descriptionController.text.isEmpty) {
      CommonDialog.showWarning(message: 'Please enter a description');
      return;
    }

    isLoading.value = true;

    try {
      final response = await _apiService.generateFaceFromText(descriptionController.text);

      if (response['success'] == true && response['generated_image'] != null) {
        final imagePath = await _saveBase64Image(response['generated_image']['image']);
        generatedImagePath.value = imagePath;

        results.value = response;

        _navigateToResults(imagePath, response);
      } else {
        CommonDialog.showError(message: 'Failed to generate face from description');
      }
    } catch (e) {
      CommonDialog.showError(message: 'Error generating face from description: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _localGenerateRandomFace() async {
    isLoading.value = true;
    try {
      OrtEnv.instance.init();

      final rawAssetFile = await rootBundle.load('lib/app/res/models/generator.onnx');
      final bytes = rawAssetFile.buffer.asUint8List();
      final sessionOptions = OrtSessionOptions();
      final session = OrtSession.fromBuffer(bytes, sessionOptions);

      const int latent = 100;
      final random = Random();
      final noiseData = Float32List(1 * latent * 1 * 1);
      for (int i = 0; i < noiseData.length; i++) {
        noiseData[i] = random.nextDouble() * 2 - 1;
      }
      final inputOrt = OrtValueTensor.createTensorWithDataList(noiseData, [latent, 1, 1]);
      final inputs = {'input': inputOrt};

      final runOptions = OrtRunOptions();
      final outputs = await session.runAsync(runOptions, inputs);

      inputOrt.release();
      runOptions.release();
      inputOrt.release();
      runOptions.release();

      final outputTensor = outputs?[0] as OrtValueTensor;
      final shape = outputTensor.value;
      print('Shape of outputTensor: $shape');
    } catch (e) {
      CommonDialog.showError(message: 'Error generating random face: $e');
    } finally {
      isLoading.value = false;
      OrtEnv.instance.release();
    }
  }

  // Uint8List _tensorToImage(OrtValueTensor tensor) {
  //   final data = tensor.getTensorData() as Float32List;
  //   final shape = tensor.getTensorShape(); // [1, 3, H, W]
  //   final H = shape[2];
  //   final W = shape[3];
  //   final image = img.Image.fromBytes(W, H, data.buffer.asUint8List(),
  //       format: img.Format.rgb);
  //
  //   // Giả sử output của Generator trong khoảng [-1, 1] (Tanh)
  //   for (int y = 0; y < H; y++) {
  //     for (int x = 0; x < W; x++) {
  //       final idx = y * W + x;
  //       final r = (data[idx] * 127.5 + 127.5).clamp(0, 255).toInt();
  //       final g = (data[H * W + idx] * 127.5 + 127.5).clamp(0, 255).toInt();
  //       final b = (data[2 * H * W + idx] * 127.5 + 127.5).clamp(0, 255).toInt();
  //       image.setPixel(x, y, img.Color.fromRgb(r, g, b));
  //     }
  //   }
  //   return Uint8List.fromList(img.encodePng(image));
  // }

  Future<String> _saveBase64Image(String base64Image) async {
    final bytes = base64Decode(base64Image);
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/generated_face_${DateTime.now().millisecondsSinceEpoch}.png';
    final File imageFile = File(imagePath);
    await imageFile.writeAsBytes(bytes);
    return imagePath;
  }

  void _navigateToResults(String imagePath, Map<String, dynamic> responseData) {
    final resultsController = ResultsController(
      imageFile: File(imagePath),
      results: responseData,
      isDetectMode: false,
    );

    Get.put<ResultsController>(resultsController);

    Get.to(
      () => const ResultsScreen(),
      binding: ResultsBinding(resultsController),
      routeName: '/results_screen'
    );
  }
}