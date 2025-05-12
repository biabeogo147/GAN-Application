import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/controller/results_controller.dart';
import 'package:mobile_app/app/service/api_service.dart';
import 'package:mobile_app/app/ui/screen/results_screen.dart';
import 'package:mobile_app/app/ui/widget/common_dialog.dart';
import 'package:path_provider/path_provider.dart';

import '../binding/results_binding.dart';

class FaceGenerationController extends GetxController {
  final ApiService _apiService = ApiService();

  // State variables
  RxBool isLoading = false.obs;
  RxString generatedImagePath = ''.obs;
  RxMap<String, dynamic> results = <String, dynamic>{}.obs;

  // Text controller for description input
  final TextEditingController descriptionController = TextEditingController();

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  // Generate random face
  Future<void> generateRandomFace() async {
    isLoading.value = true;

    try {
      final response = await _apiService.generateRandomFace();

      if (response['success'] == true && response['generated_image'] != null) {
        // Save base64 image to file
        final imagePath = await _saveBase64Image(response['generated_image']['image']);
        generatedImagePath.value = imagePath;

        // Store results
        results.value = response;

        // Navigate to results screen
        _navigateToResults(imagePath, response);
      } else {
        CommonDialog.showError(message: 'Failed to generate random face');
      }
    } catch (e) {
      CommonDialog.showError(message: 'Error generating random face: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Generate face from text description
  Future<void> generateFaceFromText() async {
    if (descriptionController.text.isEmpty) {
      CommonDialog.showWarning(message: 'Please enter a description');
      return;
    }

    isLoading.value = true;

    try {
      final response = await _apiService.generateFaceFromText(descriptionController.text);

      if (response['success'] == true && response['generated_image'] != null) {
        // Save base64 image to file
        final imagePath = await _saveBase64Image(response['generated_image']['image']);
        generatedImagePath.value = imagePath;

        // Store results
        results.value = response;

        // Navigate to results screen
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

  // Save base64 image to file
  Future<String> _saveBase64Image(String base64Image) async {
    final bytes = base64Decode(base64Image);
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/generated_face_${DateTime.now().millisecondsSinceEpoch}.png';
    final File imageFile = File(imagePath);
    await imageFile.writeAsBytes(bytes);
    return imagePath;
  }

  // Navigate to results screen
  void _navigateToResults(String imagePath, Map<String, dynamic> responseData) {
    final resultsController = ResultsController(
      imageFile: File(imagePath),
      results: responseData,
      isDetectMode: false, // Always in generation mode
    );

    // Put the controller in GetX DI
    Get.put<ResultsController>(resultsController);

    // Navigate to results screen
    Get.to(
      () => const ResultsScreen(),
      binding: ResultsBinding(resultsController),
      routeName: '/results_screen'
    );
  }
}