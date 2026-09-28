import 'package:flutter/material.dart';
import 'services/incident_api.dart';
import 'incident_evidence_screen.dart';

class IncidentScreen extends StatefulWidget {
  const IncidentScreen({super.key});

  @override
  State<IncidentScreen> createState() => _IncidentScreenState();
}

class _IncidentScreenState extends State<IncidentScreen> {
  final IncidentApi incidentApi = IncidentApi();
  List allIncidents = [];
  List filteredIncidents = [];
  
  String searchQuery = "";
  String statusFilter = "All";

  @override
  void initState() {
    super.initState();
    loadIncidents();
  }

  Future<void> loadIncidents() async {
    try {
      final data = await incidentApi.getIncidents();
      setState(() {
        allIncidents = data.reversed.toList();
        _applyFiltersAndSearch();
      });
    } catch (e) {
      print(e);
    }
  }

  void _applyFiltersAndSearch() {
    setState(() {
      filteredIncidents = allIncidents.where((incident) {
        // Search filter
        final type = (incident["incidentType"] ?? "").toString().toLowerCase();
        final desc = (incident["description"] ?? "").toString().toLowerCase();
        final id = (incident["id"] ?? "").toString().toLowerCase();
        final matchesSearch = type.contains(searchQuery.toLowerCase()) ||
            desc.contains(searchQuery.toLowerCase()) ||
            id.contains(searchQuery.toLowerCase());

        // Status filter
        final status = (incident["status"] ?? "").toString();
        final matchesStatus = statusFilter == "All" || status == statusFilter;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  String _formatDateTime(dynamic rawDateTime) {
    if (rawDateTime == null) return "01/07/2026 12:00 PM";
    try {
      DateTime parsed;
      if (rawDateTime is String) {
        parsed = DateTime.parse(rawDateTime);
      } else if (rawDateTime is List) {
        int year = rawDateTime.isNotEmpty ? (rawDateTime[0] as int) : 2026;
        int month = rawDateTime.length > 1 ? (rawDateTime[1] as int) : 1;
        int day = rawDateTime.length > 2 ? (rawDateTime[2] as int) : 1;
        int hour = rawDateTime.length > 3 ? (rawDateTime[3] as int) : 0;
        int minute = rawDateTime.length > 4 ? (rawDateTime[4] as int) : 0;
        int second = rawDateTime.length > 5 ? (rawDateTime[5] as int) : 0;
        parsed = DateTime(year, month, day, hour, minute, second);
      } else {
        return "01/07/2026 12:00 PM";
      }

      // Custom basic formatting
      String dayStr = parsed.day.toString().padLeft(2, '0');
      String monthStr = parsed.month.toString().padLeft(2, '0');
      String yearStr = parsed.year.toString();
      String hourStr = (parsed.hour > 12 ? parsed.hour - 12 : (parsed.hour == 0 ? 12 : parsed.hour)).toString().padLeft(2, '0');
      String minuteStr = parsed.minute.toString().padLeft(2, '0');
      String ampm = parsed.hour >= 12 ? "PM" : "AM";
      return "$dayStr/$monthStr/$yearStr $hourStr:$minuteStr $ampm";
    } catch (e) {
      return "01/07/2026 12:00 PM";
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "APPROVED":
        return Colors.green;
      case "REJECTED":
        return Colors.red;
      case "PENDING":
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Incident Records"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadIncidents,
          )
        ],
      ),
      body: Column(
        children: [
          // --- SEARCH & FILTER CONTROLS ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search incident...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (val) {
                      searchQuery = val;
                      _applyFiltersAndSearch();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: statusFilter,
                      items: ["All", "PENDING", "APPROVED", "REJECTED"].map((String s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            statusFilter = val;
                            _applyFiltersAndSearch();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- INCIDENT LIST ---
          Expanded(
            child: filteredIncidents.isEmpty
                ? const Center(
                    child: Text("No matching incidents found."),
                  )
                : ListView.builder(
                    itemCount: filteredIncidents.length,
                    itemBuilder: (context, index) {
                      final incident = filteredIncidents[index];
                      final incidentId = incident["id"] ?? index + 101;
                      final type = incident["incidentType"] ?? "Violence";
                      final confidence = (incident["confidence"] ?? 0.0).toDouble();
                      final description = incident["description"] ?? "";
                      final dateStr = _formatDateTime(incident["createdAt"]);
                      final status = incident["status"] ?? "PENDING";

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row 1: ID & Status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Incident #$incidentId",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: _getStatusColor(status)),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              
                              // Row 2: Date
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Row 3: Type & Confidence
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      type,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Confidence: ${confidence.toStringAsFixed(1)}%",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Row 4: Description & Action
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.visibility,
                                      color: Colors.blue,
                                      size: 26,
                                    ),
                                    onPressed: () {
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
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}