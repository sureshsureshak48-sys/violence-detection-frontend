import 'package:flutter/material.dart';
import 'services/incident_api.dart';

class IncidentScreen extends StatefulWidget {
  const IncidentScreen({super.key});

  @override
  State<IncidentScreen> createState() => _IncidentScreenState();
}

class _IncidentScreenState extends State<IncidentScreen> {

  final IncidentApi incidentApi = IncidentApi();
  List incidents = [];

  @override
  void initState() {
    super.initState();
    loadIncidents();
  }

  Future<void> loadIncidents() async {
    try {
      final data = await incidentApi.getIncidents();

      setState(() {
        incidents = data;
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
        title: const Text("Incident Management"),
      ),
      body: ListView.builder(
        itemCount: incidents.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(
                Icons.warning,
                color: Colors.red,
                size: 35,
              ),
              title: Text(
                incidents[index]["incidentType"] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Confidence: ${incidents[index]["confidence"]}",
                  ),
                  Text(
                    incidents[index]["evidencePath"] ?? "",
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}