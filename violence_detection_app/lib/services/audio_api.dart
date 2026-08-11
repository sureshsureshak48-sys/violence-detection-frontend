import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AudioApi {
  static const String baseUrl = "http://YOUR_PC_IP:5000";


  static Future<String?> detectAudio(File audioFile) async {
    try {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/detect"),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {

        var responseData =
        await response.stream.bytesToString();

        var jsonData = json.decode(responseData);

        return jsonData['result'];

      } else {
        return "Server Error";
      }

    } catch (e) {

      print("Audio API Error: $e");
      return null;

    }
  }
}