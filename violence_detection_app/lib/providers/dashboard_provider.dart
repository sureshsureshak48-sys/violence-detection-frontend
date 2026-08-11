import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int totalCameras = 0;
  int totalIncidents = 0;
  int totalAlerts = 0;

  void updateDashboard({
    required int cameras,
    required int incidents,
    required int alerts,
  }) {
    totalCameras = cameras;
    totalIncidents = incidents;
    totalAlerts = alerts;
    notifyListeners();
  }
}