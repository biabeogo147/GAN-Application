import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/ui/theme/app_colors.dart';
import 'package:mobile_app/app/res/font/app_fonts.dart';
import 'package:mobile_app/app/controller/results_controller.dart';

class ResultsScreen extends GetView<ResultsController> {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Results data: ${controller.results}");
    print("Is detect mode: ${controller.isDetectMode}");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isDetectMode ? "Detection Results" : "Generated Image",
            style: const TextStyle(
              color: AppColors.blackText,
              fontFamily: AppFonts.roboto,
              fontWeight: FontWeight.w500,
            ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blackText),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Different UI based on mode
        return controller.isDetectMode
            ? _buildDetectResults()
            : _buildGenerateResults();
      }),
    );
  }

  Widget _buildDetectResults() {
    final result = controller.results["detection_result"];
    final imageInfo = result["image_info"];
    final isFake = result["is_fake"];
    final confidence = result["confidence"];
    final analysis = result["analysis"];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original image
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Image.file(
                controller.imageFile,
                height: 300,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Result status
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isFake ? Colors.red[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isFake ? "FAKE IMAGE DETECTED" : "AUTHENTIC IMAGE",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isFake ? Colors.red[900] : Colors.green[900],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Image info
          const Text(
            "Image Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text("Width: ${imageInfo["width"]} pixels"),
          Text("Height: ${imageInfo["height"]} pixels"),
          Text("Format: ${imageInfo["format"]}"),
          const SizedBox(height: 24),

          // Analysis
          const Text(
            "Analysis",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(analysis),
          const SizedBox(height: 16),

          // Confidence score
          LinearProgressIndicator(
            value: confidence,
            backgroundColor: Colors.grey[300],
            color: _getConfidenceColor(confidence),
          ),
          const SizedBox(height: 8),
          Text(
            "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateResults() {
    final generatedImage = controller.results["generated_image"];
    final modelUsed = generatedImage["model_used"];

    final hasDescription = controller.results["description"] != null;
    final description = hasDescription ? controller.results["description"] : "";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Generated Face:",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.file(
                controller.imageFile,
                height: 300,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Generation details
          const Text(
            "Generation Details:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text("Model used: $modelUsed"),

          if (hasDescription) ...[
            const SizedBox(height: 8),
            Text("Description: $description"),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.downloadGeneratedImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Download Image",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.amber;
    return Colors.red;
  }
}