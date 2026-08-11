import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'incident_screen.dart';
import 'alert_screen.dart';
import 'evidence_screen.dart';
import 'report_screen.dart';
import 'notification_screen.dart';
import 'services/dashboard_api.dart';
import 'upload_screen.dart';
import 'control_room_screen.dart';

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

  @override
  void initState() {
    super.initState();
    loadStats();
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

             SizedBox(height: 10),

             const Text(
               "Monitor Cameras, Incidents and Alerts",
               style: TextStyle(
                 color: Colors.grey,
               ),
             ),

             SizedBox(height: 20),
             Card(
               elevation: 4,
               child: ListTile(
                 leading: const Icon(
                   Icons.videocam,
                   size: 40,
                   color: Colors.blue,
                 ),
                 title: const Text("Total Cameras"),
                 subtitle: Text(
                   "$totalCameras",
                   style: const TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             ),

             Card(
               elevation: 4,
               child: ListTile(
                 leading: const Icon(
                   Icons.warning,
                   size: 40,
                   color: Colors.orange,
                 ),
                 title: const Text("Total Incidents"),
                 subtitle: Text(
                   "$totalIncidents",
                   style: const TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             ),
             Card(
               elevation: 4,
               child: ListTile(
                 leading: const Icon(
                   Icons.notifications_active,
                   size: 40,
                   color: Colors.red,
                 ),
                 title: const Text("Total Alerts"),
                 subtitle: Text(
                   "$totalAlerts",
                   style: const TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             ),
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

                 _menuButton(
                   context,
                   "Control Room",
                   Icons.local_police,
                   const ControlRoomScreen(),
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
      elevation: 4,
      child: InkWell(
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
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}