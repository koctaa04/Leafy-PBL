import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  
  static String get baseUrl => ApiConfig.baseUrl;
  
  // Fungsi untuk memprediksi jenis daun
  static Future<Map<String, dynamic>> predictLeaf({
    required File imageFile,
    String model = 'svm', // default menggunakan SVM
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/predict?model=$model');
      
      var request = http.MultipartRequest('POST', uri);
      
      // Tambahkan file gambar ke request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );
      
      // Set timeout untuk request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - API tidak merespons dalam 30 detik');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Validasi response dari API Flask
        if (data.containsKey('model_used') && data.containsKey('prediction')) {
          return {
            'success': true,
            'data': data,
          };
        } else {
          return {
            'success': false,
            'error': 'Format response API tidak valid',
          };
        }
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['error'] ?? 'HTTP Error ${response.statusCode}',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'HTTP Error ${response.statusCode}: ${response.body}',
          };
        }
      }
    } catch (e) {
      print('API Error: $e');
      return {
        'success': false,
        'error': 'Koneksi gagal: ${e.toString()}',
      };
    }
  }
  
  // Fungsi untuk test koneksi ke API
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Test connection failed: $e');
      return false;
    }
  }
}