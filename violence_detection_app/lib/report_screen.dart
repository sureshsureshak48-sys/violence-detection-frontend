import 'package:flutter/material.dart';
import 'services/report_api.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportApi reportApi = ReportApi();
  Map<String, dynamic> stats = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReportStats();
  }

  Future<void> loadReportStats() async {
    try {
      final data = await reportApi.getStats();
      setState(() {
        stats = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print("Error loading report stats: $e");
    }
  }

  void _exportCSVReport() {
    // Generate CSV string content
    StringBuffer csv = StringBuffer();
    csv.writeln("Violence Detection System - Summary Report");
    csv.writeln("Generated Date: ,${DateTime.now().toLocal()}");
    csv.writeln("");
    csv.writeln("Metric,Value");
    csv.writeln("Total Incidents,${stats['totalIncidents'] ?? 0}");
    csv.writeln("Approved Incidents,${stats['approvedIncidents'] ?? 0}");
    csv.writeln("Rejected Incidents,${stats['rejectedIncidents'] ?? 0}");
    csv.writeln("Pending Incidents,${stats['pendingIncidents'] ?? 0}");
    csv.writeln("Total Connected Cameras,${stats['totalCameras'] ?? 0}");
    csv.writeln("Active Cameras,${stats['activeCameras'] ?? 0}");
    csv.writeln("Average Confidence (%),${stats['averageConfidence'] ?? 0.0}");
    csv.writeln("");
    csv.writeln("Violence Type Distribution");
    csv.writeln("Type,Count");
    
    final Map<String, dynamic> typeDistribution = Map<String, dynamic>.from(stats['incidentsByType'] ?? {});
    typeDistribution.forEach((key, val) {
      csv.writeln("$key,$val");
    });

    // Show export dialog with the CSV details so user can copy or keep it
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.download_done, color: Colors.green),
              SizedBox(width: 8),
              Text("Report Exported!"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "CSV Report compiled successfully. You can copy the contents below for your records:",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    csv.toString(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalIncidents = stats['totalIncidents'] ?? 0;
    final int pendingIncidents = stats['pendingIncidents'] ?? 0;
    final int approvedIncidents = stats['approvedIncidents'] ?? 0;
    final int rejectedIncidents = stats['rejectedIncidents'] ?? 0;
    
    final int totalCameras = stats['totalCameras'] ?? 0;
    final int activeCameras = stats['activeCameras'] ?? 0;
    final double averageConfidence = (stats['averageConfidence'] ?? 0.0).toDouble();
    
    final Map<String, dynamic> typeDistribution = Map<String, dynamic>.from(stats['incidentsByType'] ?? {});

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("System Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => loading = true);
              loadReportStats();
            },
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER DESCRIPTION ---
                  const Text(
                    "System Performance & Metrics",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Overview of detected incidents, camera feeds, and precision metrics.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // --- STATS GRID ---
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard("Total Incidents", "$totalIncidents", Icons.warning, Colors.red),
                      _buildStatCard("Active Cameras", "$activeCameras/$totalCameras", Icons.videocam, Colors.green),
                      _buildStatCard("Avg Confidence", "$averageConfidence%", Icons.batch_prediction, Colors.blue),
                      _buildStatCard("Pending Review", "$pendingIncidents", Icons.hourglass_empty, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- DETAILED BREAKDOWN SECTION ---
                  const Text(
                    "Incident Resolution Breakdown",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          _buildBreakdownRow("Approved & Alerted", approvedIncidents, Colors.green),
                          const Divider(),
                          _buildBreakdownRow("Rejected / False Alarms", rejectedIncidents, Colors.red),
                          const Divider(),
                          _buildBreakdownRow("Pending Review", pendingIncidents, Colors.orange),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- INCIDENT DISTRIBUTION BY TYPE ---
                  const Text(
                    "Distribution by Violence Type",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  typeDistribution.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text("No incident records available.")),
                          ),
                        )
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: typeDistribution.entries.map((entry) {
                                return ListTile(
                                  leading: const Icon(Icons.label, color: Colors.redAccent),
                                  title: Text(entry.key),
                                  trailing: CircleAvatar(
                                    backgroundColor: Colors.red.shade50,
                                    radius: 14,
                                    child: Text(
                                      "${entry.value}",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                  const SizedBox(height: 32),

                  // --- EXPORT ACTION ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _exportCSVReport,
                      icon: const Icon(Icons.file_download),
                      label: const Text(
                        "Export Summary Report (CSV)",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Text(
            "$value",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}