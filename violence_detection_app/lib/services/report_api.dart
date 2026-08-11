import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ReportApi {
  Future<List<dynamic>> getReports() async {
    final response = await http.get(
      Uri.parse(ApiService.reports),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load reports');
    }
  }
}