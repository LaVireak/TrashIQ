import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class DetectionService {
  // Try different URLs based on your setup:
  
  // For Android Emulator:
  static const String baseUrl = 'http://10.0.2.2:5000';
  
  // For Physical Device (replace with your computer's IP):
  // static const String baseUrl = 'http://192.168.1.XXX:5000';
  
  // For iOS Simulator:
  // static const String baseUrl = 'http://localhost:5000';
  
  // For debugging - add more timeout and logging
  static Future<bool> checkHealth() async {
    try {
      print('🏥 Checking health at: $baseUrl/health');
      
      // Test different URLs if the main one fails
      final testUrls = [
        '$baseUrl/health',
        'http://localhost:5000/health',
        'http://127.0.0.1:5000/health',
      ];
      
      for (String url in testUrls) {
        try {
          print('🔄 Trying URL: $url');
          final response = await http.get(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 10));

          print('🏥 Health check response for $url: ${response.statusCode}');
          if (response.statusCode == 200) {
            print('✅ Successfully connected to: $url');
            return true;
          }
        } catch (e) {
          print('❌ Failed to connect to $url: $e');
          continue;
        }
      }
      
      return false;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> detectTrash(String imagePath) async {
    try {
      print('🔍 Starting trash detection for: $imagePath');

      // Read image file
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      print('📷 Image encoded, sending to backend...');
      print('🌐 Backend URL: $baseUrl/detect');

      // Make API request with longer timeout
      final response = await http
          .post(
            Uri.parse('$baseUrl/detect'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'image': 'data:image/jpeg;base64,$base64Image'}),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        print('✅ Detection successful: $result');
        return result;
      } else {
        print('❌ Detection failed with status: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Server returned status ${response.statusCode}'
        };
      }
    } catch (e) {
      print('❌ Detection error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
