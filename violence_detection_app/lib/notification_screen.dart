import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Simulating notifications sent to users when the Control Room approves an incident
  final List<Map<String, dynamic>> systemNotifications = [
    {
      "message": "⚠️ Violence Alert: Physical Altercation verified 4km away. Please avoid the area.",
      "time": "Today, 10:00 AM",
      "icon": Icons.warning_amber_rounded,
      "color": Colors.red
    },
    {
      "message": "⚠️ Security Alert: Weapon reported 2km away. Law enforcement has been dispatched.",
      "time": "Today, 09:15 AM",
      "icon": Icons.security,
      "color": Colors.orange
    },
    {
      "message": "✅ Safe: The incident 4km away has been resolved by authorities.",
      "time": "Yesterday, 08:30 PM",
      "icon": Icons.verified_user,
      "color": Colors.green
    },
    {
      "message": "⚠️ Violence Alert: Group fighting confirmed 5km away. Stay safe.",
      "time": "Yesterday, 02:00 PM",
      "icon": Icons.warning_amber_rounded,
      "color": Colors.red
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Notifications"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: systemNotifications.length,
        itemBuilder: (context, index) {
          final notification = systemNotifications[index];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification["color"].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification["icon"],
                  color: notification["color"],
                  size: 28,
                ),
              ),
              title: Text(
                notification["message"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  "Logged: ${notification["time"]}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}