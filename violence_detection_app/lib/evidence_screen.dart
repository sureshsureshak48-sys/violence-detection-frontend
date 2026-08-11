import 'package:flutter/material.dart';
import 'services/evidence_api.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() =>
      _EvidenceScreenState();
}

class _EvidenceScreenState
    extends State<EvidenceScreen> {

  final EvidenceApi evidenceApi =
  EvidenceApi();

  List evidenceList = [];

  @override
  void initState() {
    super.initState();
    loadEvidence();
  }

  Future<void> loadEvidence() async {

    final data =
    await evidenceApi.getEvidence();

    setState(() {
      evidenceList = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Evidence Management",
        ),
      ),

      body: ListView.builder(
        itemCount: evidenceList.length,

        itemBuilder: (context, index) {

          return Card(
            elevation: 4,
            margin:
            const EdgeInsets.all(8),

            child: ListTile(
              leading: Icon(

                evidenceList[index]
                ["fileType"] ==
                    "VIDEO"

                    ? Icons.video_file
                    : Icons.image,

                size: 35,
              ),

              title: Text(
                evidenceList[index]
                ["filePath"] ??
                    "",
              ),

              subtitle: Text(
                evidenceList[index]
                ["fileType"] ??
                    "",
              ),
            ),
          );
        },
      ),
    );
  }
}