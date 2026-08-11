import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

Future<void> initFcm(int userId) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();

  String? token = await messaging.getToken();

  if (token != null) {
    await http.post(
      Uri.parse("${ApiService.baseUrl}/fcm/save"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "fcmToken": token}),
    );
    print("FCM token saved");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Notification: ${message.notification?.title}");
  });
}