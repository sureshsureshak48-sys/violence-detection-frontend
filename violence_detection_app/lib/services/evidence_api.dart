import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class EvidenceApi {

  Future<List<dynamic>> getEvidence() async {

    final response =
    await http.get(
      Uri.parse(ApiService.evidence),
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );

    } else {

      throw Exception(
        "Failed to load evidence",
      );
    }
  }
}