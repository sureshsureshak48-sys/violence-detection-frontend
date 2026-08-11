import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class DashboardApi {

  Future<Map<String, dynamic>> getStats() async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/dashboard/stats"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load dashboard stats");
    }
  }
}