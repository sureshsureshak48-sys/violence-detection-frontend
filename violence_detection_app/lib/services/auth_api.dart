import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthApi {

  Future<Map<String, dynamic>> login(String username, String password) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    return jsonDecode(response.body);
  }
}