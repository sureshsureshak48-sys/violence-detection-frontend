import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class RegisterApi {

  Future<String> registerUser(
      String fullName,
      String email,
      String mobile,
      String username,
      String password,
      ) async {

    final response = await http.post(
      Uri.parse(ApiService.register),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "fullName": fullName,
        "email": email,
        "mobile": mobile,
        "username": username,
        "password": password,
        "role": "USER"
      }),
    );

    return response.body;
  }
}