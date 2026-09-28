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
          String message = alerts[index]["message"] ?? "Violence Detected!";
          // Fix old database entries that have "detected detected"
          message = message.replaceAll(RegExp(r'detected\s+detected', caseSensitive: false), 'detected');
          // Capitalize first letter
          if (message.isNotEmpty) {
            message = message[0].toUpperCase() + message.substring(1);
          }

          String rawTime = alerts[index]["alertTime"] ?? 'Unknown';
          // Format ugly ISO timestamp (e.g. 2026-08-13T14:20:08.738467)
          if (rawTime.contains("T")) {
            try {
              DateTime dt = DateTime.parse(rawTime);
              String amPm = dt.hour >= 12 ? "PM" : "AM";
              int hour12 = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
              String minute = dt.minute.toString().padLeft(2, '0');
              rawTime = "${dt.day}-${dt.month}-${dt.year} $hour12:$minute $amPm";
            } catch (e) {
              // Ignore parse error, use raw
            }
          }

          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              title: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    "Time: $rawTime",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (alerts[index]["cameraName"] != null)
                    Text(
                      "Camera: ${alerts[index]["cameraName"]}",
                      style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}