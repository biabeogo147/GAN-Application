import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';
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
      final ort = OnnxRuntime();
      final session = await ort.createSessionFromAsset('lib/app/res/models/generator.onnx');

      final inputName1 = session.inputNames[0];
      final inputName2 = session.inputNames[1];
      final outputName = session.outputNames[0];

      final inputs = {
        inputName1: await OrtValue.fromList([1, 1, 1], [3]),
        inputName2: await OrtValue.fromList([2, 2, 2], [3])
      }

      final outputs = await session.run(inputs);

      print(await outputs[outputName]!.asList());

      for (final tensor in inputs.values) {
        tensor.dispose();
      }
      for (final tensor in outputs.values) {
        tensor.dispose();
      }
      await session.close();

      // const int latent = 100;
      // final random = Random();
      // final noiseData = Float32List(1 * latent * 1 * 1);
      // for (int i = 0; i < noiseData.length; i++) {
      //   noiseData[i] = random.nextDouble() * 2 - 1;
      // }
    } catch (e) {
      CommonDialog.showError(message: 'Error generating random face: $e');
    } finally {
      isLoading.value = false;
      OrtEnv.instance.release();
    }
  }

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