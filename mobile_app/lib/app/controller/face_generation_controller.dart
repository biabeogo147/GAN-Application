import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:mobile_app/app/service/api_service.dart';
import 'package:mobile_app/app/ui/widget/common_dialog.dart';
import 'package:mobile_app/app/binding/results_binding.dart';
import 'package:mobile_app/app/ui/screen/results_screen.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:mobile_app/app/controller/results_controller.dart';

class FaceGenerationController extends GetxController {
  final ApiService _apiService = ApiService();

  RxBool isLoading = false.obs;

  OrtSession? _session;
  String? _selectedProvider;
  List<OrtProvider> _availableProviders = [];
  final String generatorPath = 'lib/app/res/models/generator.onnx';

  static const int width = 64;
  static const int height = 64;
  static const int channels = 3;
  static const int latent = 100;

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
      List<Map<String, dynamic>> modelInfo = await _getModelInfo();
      print('Model Info: $modelInfo');
      _generatorInference();
    } catch (e) {
      CommonDialog.showError(message: 'Error generating random face: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _getModelInfo() async {
    _session ??= await OnnxRuntime().createSessionFromAsset(generatorPath);
    _availableProviders = await OnnxRuntime().getAvailableProviders();
    _selectedProvider = _availableProviders.isNotEmpty ? _availableProviders[0].name : null;

    final modelMetadata = await _session?.getMetadata();
    final modelMetadataMap = modelMetadata?.toMap();
    final List<Map<String, dynamic>> modelInputInfoMap = await _session!.getInputInfo();
    final List<Map<String, dynamic>> modelOutputInfoMap = await _session!.getOutputInfo();

    final displayList = [
      {'title': 'Model Name', 'value': generatorPath.split('/').last},
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

  Future<void> _generatorInference() async {
    OrtProvider provider;
    if (_selectedProvider == null) {
      provider = OrtProvider.CPU;
    } else {
      provider = OrtProvider.values.firstWhere((p) => p.name == _selectedProvider);
    }

    final sessionOptions = OrtSessionOptions(providers: [provider]);
    _session ??= await OnnxRuntime().createSessionFromAsset(generatorPath, options: sessionOptions);

    final String inputName = _session!.inputNames.first;
    final String outputName = _session!.outputNames.first;
    final List<double> inputData = await _getRandomLatentVector(latent, mean: 0.0, std: 1.0);
    OrtValue inputTensor = await OrtValue.fromList(
      inputData,
      [1, latent, 1, 1],
    );

    final outputs = await _session!.run({
      inputName: inputTensor,
    });
    final outputTensor = [await outputs[outputName]!.asList()][0][0];

    final image = img.Image(width: width, height: height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int r, g, b;
        if (channels == 3) {
          r = (outputTensor[0][y][x] * 255).clamp(0, 255).toInt();
          g = (outputTensor[1][y][x] * 255).clamp(0, 255).toInt();
          b = (outputTensor[2][y][x] * 255).clamp(0, 255).toInt();
        } else {
          r = g = b = (outputTensor[0][y][x] * 255).clamp(0, 255).toInt();
        }
        image.setPixel(x, y, img.ConstColorRgb8(r, g, b));
      }
    }

    await inputTensor.dispose();
    for (var output in outputs.values) {
      await output.dispose();
    }

    String imagePath = await _saveImage(image);
    Map<String, dynamic> response = {
      'success': true,
      'generated_image': {
        'width': width,
        'height': height,
        'channels': channels,
        'image': base64Encode(image.getBytes()),
        'model_used': generatorPath.split('/').last,
      },
    };
    _navigateToResults(imagePath, response);
  }

  Future<List<double>> _getRandomLatentVector(int length, {double mean = 0.0, double std = 1.0}) async {
    Random random = Random();
    List<double> noise = [];

    for (int i = 0; i < length; i += 2) {
      double u1 = random.nextDouble();
      double u2 = random.nextDouble();

      if (u1 == 0) u1 = 1e-10;

      double z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
      double z1 = sqrt(-2.0 * log(u1)) * sin(2.0 * pi * u2);

      noise.add(mean + std * z0);
      if (i + 1 < length) {
        noise.add(mean + std * z1);
      }
    }

    return noise;
  }

  Future<String> _saveImage(img.Image image) async {
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/generated_face_${DateTime.now().millisecondsSinceEpoch}.png';
    final File imageFile = File(imagePath);
    await imageFile.writeAsBytes(img.encodePng(image));
    return imagePath;
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