import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {

  List alerts = [];

  @override
  void initState() {
    super.initState();
    loadAlerts();
  }

  Future<void> loadAlerts() async {

    final response = await http.get(
      Uri.parse(
        "${ApiService.alerts}/all",
      ),
    );

    if (response.statusCode == 200) {

      setState(() {
        alerts = jsonDecode(
          response.body,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {

          final alert = alerts[index];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: Colors.red,
              ),
              title: Text(
                alert["message"] ?? "",
              ),
            ),
          );
        },
      ),
    );
  }
}