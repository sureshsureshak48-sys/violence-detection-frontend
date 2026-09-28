import 'package:flutter/material.dart';
import 'services/camera_api.dart';

class CameraAddScreen extends StatefulWidget {
  const CameraAddScreen({super.key});

  @override
  State<CameraAddScreen> createState() =>
      _CameraAddScreenState();
}

class _CameraAddScreenState
    extends State<CameraAddScreen> {

  final cameraNameController =
  TextEditingController();

  final rtspController =
  TextEditingController();


  final CameraApi cameraApi = CameraApi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Camera"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: cameraNameController,
              decoration: const InputDecoration(
                labelText: "Camera Name",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: rtspController,
              decoration: const InputDecoration(
                labelText: "RTSP URL",
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () async {

                if (cameraNameController.text.isEmpty ||
                    rtspController.text.isEmpty) {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please fill all fields",
                      ),
                    ),
                  );

                  return;
                }

                bool success =
                await cameraApi.saveCamera(
                  cameraNameController.text,
                  rtspController.text,
                  "Active", // Automatically set status to Active
                );

                if (success) {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Camera Saved Successfully",
                      ),
                    ),
                  );

                  Navigator.pop(context);

                } else {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Failed to Save Camera",
                      ),
                    ),
                  );

                }
              },
              child: const Text(
                "Save Camera",
              ),
            ),

          ],
        ),
      ),
    );
  }
}