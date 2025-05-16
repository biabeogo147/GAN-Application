// lib/app/controller/results_controller.dart
import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ResultsController extends GetxController {
  final File imageFile;
  final Map<String, dynamic> results;
  final bool isDetectMode;
  final RxBool isLoading = false.obs;

  ResultsController({
    required this.imageFile,
    required this.results,
    required this.isDetectMode,
  });

  Future<void> downloadGeneratedImage() async {
    try {
      isLoading.value = true;

      if (results['generated_image'] != null &&
          results['generated_image']['image'] != null) {
        final base64Image = results['generated_image']['image'];
        final bytes = base64Decode(base64Image);

        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempPath = '${tempDir.path}/generated_image_$timestamp.png';

        final file = File(tempPath);
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([XFile(tempPath)], text: 'Generated Image');

        isLoading.value = false;
      } else {
        isLoading.value = false;
        Get.snackbar('Error', 'No generated image available',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to download image: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}