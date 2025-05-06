import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mobile_app/app/ui/widget/common_dialog.dart';

class ApiService {
  final Dio _dio = Dio();
  // final String baseUrl = 'http://10.0.2.2:8000'; // Update with your actual server address

  // For iOS Simulator:
  final String baseUrl = 'http://localhost:8000';

  // For physical devices:
  // final String baseUrl = 'http://YOUR-COMPUTER-IP:8000';

  // Configure API settings
  ApiService() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Convert image file to base64
  Future<String> imageToBase64(String imagePath) async {
    final File imageFile = File(imagePath);
    final List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  // Send image to server
  Future<Map<String, dynamic>> uploadImage(String imagePath) async {
    try {
      // Convert image to base64
      final String base64Image = await imageToBase64(imagePath);

      // Prepare request data
      final Map<String, dynamic> data = {
        'image': base64Image,
      };

      // Send request to server
      final response = await _dio.post(
        '$baseUrl/api/process-image',
        data: data,
      );

      return response.data;
    } catch (e) {
      CommonDialog.showError(message: 'Failed to upload image: $e');
      return {'error': e.toString()};
    }
  }
}