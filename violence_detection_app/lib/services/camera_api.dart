import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class CameraApi {

  Future<List<dynamic>> getCameras() async {

    final response = await http.get(
      Uri.parse(ApiService.cameras),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load cameras');
    }
  }

  Future<bool> saveCamera(
      String cameraName,
      String rtspUrl,
      String status,
      ) async {

    final response = await http.post(
      Uri.parse(ApiService.cameras),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "cameraName": cameraName,
        "rtspUrl": rtspUrl,
        "status": status,
      }),
    );

    return response.statusCode == 200 ||
        response.statusCode == 201;
  }
}