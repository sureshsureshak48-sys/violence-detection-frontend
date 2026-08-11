import 'package:flutter/material.dart';

class AlertProvider extends ChangeNotifier {
  List alerts = [];

  void setAlerts(List data) {
    alerts = data;
    notifyListeners();
  }
}