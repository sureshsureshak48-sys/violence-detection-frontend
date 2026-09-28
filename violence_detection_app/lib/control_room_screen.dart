import 'package:flutter/material.dart';
import 'services/control_room_api.dart';
import 'incident_evidence_screen.dart';

class ControlRoomScreen extends StatefulWidget {
  const ControlRoomScreen({super.key});

  @override
  State<ControlRoomScreen> createState() => _ControlRoomScreenState();
}

class _ControlRoomScreenState extends State<ControlRoomScreen> {

  final ControlRoomApi controlRoomApi = ControlRoomApi();
  List incidents = [];
  bool loading = true;

  Map<int, String> selectedTypes = {};

  final List<String> typeOptions = [
    "Group Fight",
    "Assault/Fight",
    "Physical altercation",
    "Group altercation",
    "Possible armed incident",
    "Robbery",
    "Suspicious Activity",
  ];

  @override
  void initState() {
    super.initState();
    loadIncidents();
  }

  Future<void> loadIncidents() async {
    setState(() => loading = true);
    try {
      final data = await controlRoomApi.getPendingIncidents();
      setState(() {
        incidents = data.reversed.toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print(e);
    }
  }

  Future<void> approve(int id) async {
    String type = selectedTypes[id] ?? "Violence detected";
    await controlRoomApi.approveIncident(id, type);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Incident Approved, alert sent")),
    );
    loadIncidents();
  }

  Future<void> reject(int id) async {
    await controlRoomApi.rejectIncident(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Incident Rejected")),
    );
    loadIncidents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Control Room"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : incidents.isEmpty
          ? const Center(child: Text("No pending incidents"))
          : RefreshIndicator(
        onRefresh: loadIncidents,
        child: ListView.builder(
          itemCount: incidents.length,
          itemBuilder: (context, index) {
            final incident = incidents[index];

            return Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IncidentEvidenceScreen(
                        incidentId: incident["id"],
                        incidentType: incident["incidentType"] ?? "Unknown",
                        createdAt: incident["createdAt"] ?? "Unknown Time",
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident["incidentType"] ?? "Unknown",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Confidence: ${incident["confidence"]}%",
                    ),
                    const SizedBox(height: 12),

                    DropdownButton<String>(
                      isExpanded: true,

                      value: selectedTypes[incident["id"]],

                      hint: Text(
                        incident["incidentType"] ?? "Select Type",
                      ),

                      items: typeOptions.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),

                      onChanged: (value) {
                        setState(() {
                          selectedTypes[incident["id"]] = value!;
                        });
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => reject(incident["id"]),
                          child: const Text("Reject"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () => approve(incident["id"]),
                          child: const Text("Approve"),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}