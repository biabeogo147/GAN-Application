import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:mobile_app/app/ui/widget/common_dialog.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://mature-radically-orca.ngrok-free.app';

  ApiService() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        }
    );
  }

  Future<String> imageToBase64(String imagePath) async {
    final File imageFile = File(imagePath);
    final List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<Map<String, dynamic>> detectFakeImage(String imagePath) async {
    try {
      final String base64Image = await imageToBase64(imagePath);
      final Map<String, dynamic> data = {
        'image': base64Image,
      };
      final response = await _dio.get(
        '$baseUrl/api/process-image',
        data: data,
      );
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> generateRandomFace() async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/generate-face',
        data: {'type': 'random'},
      );
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Generate face from text description
  Future<Map<String, dynamic>> generateFaceFromText(String description) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/generate-face',
        data: {
          'type': 'text-to-image',
          'description': description
        },
      );
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}