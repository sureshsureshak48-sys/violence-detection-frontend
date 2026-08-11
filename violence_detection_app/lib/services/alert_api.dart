import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AlertApi {

  Future<List<dynamic>> getAlerts() async {

    final response = await http.get(
      Uri.parse(ApiService.alerts),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load alerts');
    }
  }
}