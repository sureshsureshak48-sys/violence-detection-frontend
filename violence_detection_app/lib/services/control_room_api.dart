import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ControlRoomApi {

  Future<List<dynamic>> getPendingIncidents() async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/control-room/pending"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load pending incidents');
    }
  }

  Future<String> approveIncident(int id, String violenceType) async {
    final response = await http.put(
      Uri.parse("${ApiService.baseUrl}/control-room/approve/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"violenceType": violenceType}),
    );
    return response.body;
  }

  Future<String> rejectIncident(int id) async {

    final response = await http.put(
      Uri.parse("${ApiService.baseUrl}/control-room/reject/$id"),
    );

    return response.body;
  }
}