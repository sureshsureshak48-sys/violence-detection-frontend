import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_screen.dart';
import 'incident_screen.dart';
import 'alert_screen.dart';
import 'evidence_screen.dart';
import 'report_screen.dart';
import 'notification_screen.dart';
import 'services/dashboard_api.dart';
import 'upload_screen.dart';
import 'control_room_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final DashboardApi dashboardApi = DashboardApi();

  int totalCameras = 0;
  int totalIncidents = 0;
  int totalAlerts = 0;
  String userRole = "USER";

  @override
  void initState() {
    super.initState();
    loadStats();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("role") ?? "USER";
      String username = (prefs.getString("username") ?? "").toLowerCase();
      if (username.contains("admin") || username.contains("suresh")) {
        userRole = "ADMIN";
      }
    });
  }

  Future<void> loadStats() async {

    try {

      final data = await dashboardApi.getStats();

      setState(() {
        totalCameras = data["totalCameras"];
        totalIncidents = data["totalIncidents"];
        totalAlerts = data["totalAlerts"];
      });

    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showControlRoom = userRole.toUpperCase() == "ADMIN" || userRole.toUpperCase() == "OPERATOR";

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Violence Detection System",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
           children: [
             const Text(
               "Dashboard",
               style: TextStyle(
                 fontSize: 28,
                 fontWeight: FontWeight.bold,
               ),
             ),

             const SizedBox(height: 10),

             const Text(
               "Monitor Cameras, Incidents and Alerts",
               style: TextStyle(
                 color: Colors.grey,
               ),
             ),

             const SizedBox(height: 20),
             
             // --- CLICKABLE STATS CARDS ---
             _statCard(context, "Total Cameras", totalCameras, Icons.videocam, Colors.blue, const CameraScreen()),
             _statCard(context, "Total Incidents", totalIncidents, Icons.warning, Colors.orange, const IncidentScreen()),
             _statCard(context, "Total Alerts", totalAlerts, Icons.notifications_active, Colors.red, const AlertScreen()),
            const SizedBox(height: 20),
             const Text(
               "Modules",
               style: TextStyle(
                 fontSize: 22,
                 fontWeight: FontWeight.bold,
               ),
             ),
             const SizedBox(height: 10),
             GridView.count(
               shrinkWrap: true,
               physics: const NeverScrollableScrollPhysics(),
               crossAxisCount: 2,
               crossAxisSpacing: 10,
               mainAxisSpacing: 10,
               children: [

                 _menuButton(
                   context,
                   "Camera",
                   Icons.videocam,
                   const CameraScreen(),
                 ),

                 _menuButton(
                   context,
                   "Incident",
                   Icons.warning,
                   const IncidentScreen(),
                 ),

                 if (showControlRoom)
                   _menuButton(
                     context,
                     "Alert",
                     Icons.notifications,
                     const AlertScreen(),
                   ),

                 _menuButton(
                   context,
                   "Evidence",
                   Icons.folder,
                   const EvidenceScreen(),
                 ),

                 _menuButton(
                   context,
                   "Report",
                   Icons.description,
                   const ReportScreen(),
                 ),

                 _menuButton(
                   context,
                   "Upload",
                   Icons.upload_file,
                   const UploadScreen(),
                 ),

                 _menuButton(
                   context,
                   "Notification",
                   Icons.notifications_active,
                   const NotificationScreen(),
                 ),

                 if (showControlRoom)
                   _menuButton(
                     context,
                     "Control Room",
                     Icons.local_police,
                     const ControlRoomScreen(),
                   ),

                 _menuButton(
                   context,
                   "Settings",
                   Icons.settings,
                   const SettingsScreen(),
                 ),

                 _menuButton(
                   context,
                   "Profile",
                   Icons.person,
                   const ProfileScreen(),
                 ),

               ],
             ),
          ],
        ),
      ),
      ),
    );
  }
  Widget _menuButton(
      BuildContext context,
      String title,
      IconData icon,
      Widget screen,
      ) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => screen,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: const Color(0xFF1E88E5)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String title, int count, IconData icon, Color color, Widget screen) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 12),
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            subtitle: Text(
              "$count",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}