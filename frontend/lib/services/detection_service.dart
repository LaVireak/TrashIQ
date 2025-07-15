import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class DetectionService {
  // Use the IP address from your server output
  static const String baseUrl =
      'http://10.120.122.128:5000'; // or 'http://127.0.0.1:5000'

  static Future<Map<String, dynamic>> detectTrash(String imagePath) async {
    try {
      print('🔍 Starting trash detection for: $imagePath');

      // Read image file
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      print('📷 Image encoded, sending to backend...');

      // Make API request
      final response = await http
          .post(
            Uri.parse('$baseUrl/detect'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'image': 'data:image/jpeg;base64,$base64Image'}),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Backend response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Detection result: ${result['success']}');
        if (result['success']) {
          print(
            '🎯 Detected: ${result['detection']?['name']} (${result['detection']?['confidence']}%)',
          );
        }
        return result;
      } else {
        throw Exception('Detection failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Detection error: $e');
      throw Exception('Error detecting trash: $e');
    }
  }

  static Future<Map<String, dynamic>> getAvailableClasses() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/classes'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get classes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting classes: $e');
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🏥 Backend health: ${data['status']}');
        print('🤖 Model loaded: ${data['model_loaded']}');
        print('📊 Total classes: ${data['total_classes']}');
        return data['status'] == 'healthy' && data['model_loaded'] == true;
      }
      return false;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }
}
