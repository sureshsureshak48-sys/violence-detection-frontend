import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'services/auth_api.dart';
import 'register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/api_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  const AndroidNotificationChannel channel = AndroidNotificationChannel( 'high_importance_channel', 'High Importance Notifications', importance: Importance.high, );
  await flutterLocalNotificationsPlugin .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>() ?.createNotificationChannel(channel);


  String? token =
  await FirebaseMessaging.instance.getToken();

  print("FCM TOKEN = $token");

  runApp(const MyApp());
}

Future<void> initFcm(int userId) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  String? token = await messaging.getToken();

  if (token != null) {
    await http.post(
      Uri.parse(ApiService.fcmSave),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "fcmToken": token}),
    );
    print("FCM token saved");
  }
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final AuthApi authApi = AuthApi();

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Violence Detection System",
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 40),

              const Icon(
                Icons.security,
                size: 100,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Login to continue",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword =
                        !hidePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed: () async {

                    if (usernameController.text.isEmpty ||
                        passwordController.text.isEmpty) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please fill all fields",
                          ),
                        ),
                      );

                      return;
                    }

                    print("Login Button Clicked");

                    Map<String, dynamic> result =
                    await authApi.login(
                      usernameController.text,
                      passwordController.text,
                    );

                    print(result);

                    if (result["status"] == "Login Success") {

                      int userId = result["userId"];
                      await initFcm(userId);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const DashboardScreen(),
                        ),
                      );

                    } else {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Invalid Username or Password",
                          ),
                        ),
                      );

                    }
                  },

                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const RegisterScreen(),
                    ),
                  );

                },

                child: const Text(
                  "New User? Register Here",
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}