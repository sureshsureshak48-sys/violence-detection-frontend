import 'package:flutter/material.dart';
import 'services/alert_api.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {

  final AlertApi alertApi = AlertApi();
  List alerts = [];

  @override
  void initState() {
    super.initState();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    try {
      final data = await alertApi.getAlerts();

      setState(() {
        alerts = data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Alert Management"),
      ),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: Colors.orange,
                size: 35,
              ),
              title: Text(
                alerts[index]["message"] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                alerts[index]["alertTime"] ?? "",
              ),
            ),
          );
        },
      ),
    );
  }
}