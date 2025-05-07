// lib/app/controller/results_controller.dart
import 'dart:io';
import 'package:get/get.dart';

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
}