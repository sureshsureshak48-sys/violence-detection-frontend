import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Reports"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: const [

          Card(
            elevation: 4,
            child: ListTile(
              leading: Icon(
                Icons.description,
                color: Colors.green,
                size: 35,
              ),
              title: Text(
                "Daily Security Report",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "1 violence incident detected",
              ),
              trailing: Icon(Icons.visibility),
            ),
          ),

          Card(
            elevation: 4,
            child: ListTile(
              leading: Icon(
                Icons.analytics,
                color: Colors.blue,
                size: 35,
              ),
              title: Text(
                "Weekly Analysis Report",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Incident statistics summary",
              ),
              trailing: Icon(Icons.visibility),
            ),
          ),

        ],
      ),
    );
  }
}