import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/camera_api.dart';
import 'services/api_service.dart';
import 'camera_add_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraApi cameraApi = CameraApi();
  List cameras = [];
  bool loading = true;
  Set<int> activeCameraIds = {};

  @override
  void initState() {
    super.initState();
    loadCameras();
  }

  Future<void> loadCameras() async {
    setState(() => loading = true);
    try {
      final data = await cameraApi.getCameras();
      setState(() {
        cameras = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print(e);
    }
  }

  Future<void> startDetection(int cameraId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/cameras/startDetection/$cameraId"),
      );

      if (response.statusCode == 200) {
        setState(() {
          activeCameraIds.add(cameraId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Detection started for this camera")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to start detection")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> stopDetection() async {
    try {
      await http.post(
        Uri.parse("${ApiService.baseUrl}/cameras/stopDetection"),
      );
      setState(() {
        activeCameraIds.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Detection stopped")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Cameras"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraAddScreen()),
          );
          loadCameras();
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : cameras.isEmpty
          ? const Center(child: Text("No cameras added yet"))
          : RefreshIndicator(
        onRefresh: loadCameras,
        child: ListView.builder(
          itemCount: cameras.length,
          itemBuilder: (context, index) {
            final camera = cameras[index];
            final int camId = camera["id"];
            final bool isActive = activeCameraIds.contains(camId);

            return Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.videocam,
                          color: isActive ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            camera["cameraName"] ?? "Unnamed Camera",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isActive)
                          const Chip(
                            label: Text("LIVE"),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text("RTSP: ${camera["rtspUrl"] ?? ""}"),
                    Text("Status: ${camera["status"] ?? ""}"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!isActive)
                          ElevatedButton.icon(
                            onPressed: () => startDetection(camId),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text("Start Monitoring"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: stopDetection,
                            icon: const Icon(Icons.stop),
                            label: const Text("Stop"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
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
    );
  }
}