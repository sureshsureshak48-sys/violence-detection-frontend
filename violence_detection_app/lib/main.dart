import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'splash_screen.dart';
import 'services/auth_api.dart';
import 'register_screen.dart';
import 'incident_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/api_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _handleNotificationPayload(String? payload) {
  if (payload != null && payload.isNotEmpty) {
    try {
      final data = jsonDecode(payload);
      if (data["screen"] == "incidents") {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const IncidentScreen(),
          ),
        );
      }
    } catch (e) {
      print("Error parsing notification payload: $e");
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background notification: ${message.notification?.title}");
}

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  
  final InitializationSettings initSettings = const InitializationSettings(android: androidSettings);
  
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      _handleNotificationPayload(response.payload);
    },
  );
  
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'silent_notification_channel', 
    'Silent Notifications', 
    importance: Importance.defaultImportance,
    playSound: false,
  );
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM TOKEN = $token");

  // Handle tap when app was terminated
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      final payload = jsonEncode(message.data);
      _handleNotificationPayload(payload);
    }
  });

  // Handle tap when app was in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final payload = jsonEncode(message.data);
    _handleNotificationPayload(payload);
  });

  // Register device FCM listener on app startup
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      final payload = jsonEncode(message.data);
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'silent_notification_channel',
            'Silent Notifications',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            playSound: false,
          ),
        ),
        payload: payload,
      );
    }
  });

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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          labelStyle: const TextStyle(color: Colors.black54),
          prefixIconColor: Colors.black54,
        ),
      ),
      home: const SplashScreen(),
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

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt("userId", userId);
                      await prefs.setString("role", result["role"] ?? "USER");
                      await prefs.setString("username", usernameController.text);

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