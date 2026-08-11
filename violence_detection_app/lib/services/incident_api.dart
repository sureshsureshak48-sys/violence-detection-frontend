import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class IncidentApi {

  Future<List<dynamic>> getIncidents() async {

    final response = await http.get(
      Uri.parse(ApiService.incidents),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load incidents');
    }
  }
}