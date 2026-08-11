import 'package:flutter/material.dart';

class IncidentProvider extends ChangeNotifier {
  List incidents = [];

  void setIncidents(List data) {
    incidents = data;
    notifyListeners();
  }
}