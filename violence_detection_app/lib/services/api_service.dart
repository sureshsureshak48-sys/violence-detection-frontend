class ApiService {

  static const String baseUrl =
      "http://10.49.211.63:8081";
  static const String flaskUrl = "http://10.49.211.63:5000";

  static const String login =
      "$baseUrl/auth/login";

  static const String register =
      "$baseUrl/register";

  static const String users =
      "$baseUrl/users";

  static const String cameras =
      "$baseUrl/cameras";

  static const String incidents =
      "$baseUrl/incidents";

  static const String alerts =
      "$baseUrl/alerts";

  static const String evidence =
      "$baseUrl/evidence";

  static const String reports =
      "$baseUrl/reports";

  static const String upload =
      "$baseUrl/media/upload";

  static const String detect=
      "$baseUrl/detect";

  static const String fcmSave =
      "$baseUrl/fcm/save";


  static const String detectAudio =
      "$flaskUrl/detect-audio";

}