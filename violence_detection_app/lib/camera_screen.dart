import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadCameras() async {
    setState(() => loading = true);
    try {
      final data = await cameraApi.getCameras();
      
      // Fetch active camera status
      final statusResponse = await http.get(Uri.parse("${ApiService.baseUrl}/cameras/status"));
      
      setState(() {
        cameras = data;
        activeCameraIds.clear();
        if (statusResponse.statusCode == 200 && statusResponse.body.isNotEmpty) {
          int? activeId = int.tryParse(statusResponse.body);
          if (activeId != null) {
            activeCameraIds.add(activeId);
          }
        }
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print(e);
    }
  }

  Future<void> startDetection(int cameraId, String rtspUrl) async {
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

  Future<void> stopDetection(int cameraId) async {
    try {
      await http.post(
        Uri.parse("${ApiService.baseUrl}/cameras/stopDetection"),
      );
      setState(() {
        activeCameraIds.remove(cameraId);
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

  Future<void> deleteCamera(int id) async {
    try {
      bool success = await cameraApi.deleteCamera(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera deleted")),
        );
        loadCameras();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete camera")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Camera"),
        content: const Text("Are you sure you want to delete this camera?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteCamera(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(camId),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text("RTSP: ${camera["rtspUrl"] ?? ""}"),
                    Text("Status: ${camera["status"] ?? ""}"),
                    const SizedBox(height: 10),
                    
                    // Show live video if active
                    if (isActive)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: AspectRatio(
                            aspectRatio: 4 / 3, // Standard camera aspect ratio
                            child: Mjpeg(
                              isLive: true,
                              stream: camera["rtspUrl"] ?? "",
                              error: (context, error, stack) {
                                return Center(
                                  child: Text(
                                    "Error connecting to stream.\nEnsure URL ends with /video",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!isActive)
                          ElevatedButton.icon(
                            onPressed: () => startDetection(camId, camera["rtspUrl"] ?? ""),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text("Start Monitoring"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () => stopDetection(camId),
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