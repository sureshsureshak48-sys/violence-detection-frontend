import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'services/media_api.dart';
import 'dart:convert';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String detectionResult = "";
  final MediaApi mediaApi = MediaApi();

  // ---------------- IMAGE ----------------
  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      String apiResponse = await mediaApi.uploadImage(filePath);
      _showObjectResult(apiResponse);
    }
  }

  Future<void> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      String apiResponse = await mediaApi.uploadVideo(filePath);
      _showVideoResult(apiResponse);
    }
  }
  Future<void> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      String apiResponse = await mediaApi.uploadAudio(filePath);
      _showAudioResult(apiResponse);
    }
  }

  void _showObjectResult(String apiResponse) {
    Map<String, dynamic> data = jsonDecode(apiResponse);

    String summary = "";

    if (data.containsKey("violence")) {
      bool violence = data["violence"] ?? false;
      double confidence = (data["confidence"] ?? 0).toDouble();
      String type = data["overall_violence_type"] ?? "N/A";

      summary = violence ? "⚠️ VIOLENCE DETECTED\n" : "✅ No Violence\n";
      summary += "Type: $type\nConfidence: $confidence%\n\n";
    }

    Map<String, dynamic> objects = data["objects"] ?? {};
    objects.forEach((key, value) {
      summary += "${key.toUpperCase()} : $value\n";
    });

    setState(() {
      detectionResult = summary;
    });

    _showSnack("Image analyzed successfully");
  }

  // ---------------- Display: video/violence result ----------------
  void _showVideoResult(String apiResponse) {
    Map<String, dynamic> data = jsonDecode(apiResponse);

    bool violence = data["violence"] ?? false;
    double confidence = (data["confidence"] ?? 0).toDouble();
    String violenceType = data["overall_violence_type"] ?? "N/A";
    Map<String, dynamic> objects = data["objects"] ?? {};

    String summary = violence
        ? "⚠️ VIOLENCE DETECTED\n"
        : "✅ No Violence Detected\n";

    summary += "Type: $violenceType\n";
    summary += "Confidence: $confidence%\n\n";

    objects.forEach((key, value) {
      summary += "${key.toUpperCase()} : $value\n";
    });

    setState(() {
      detectionResult = summary;
    });

    _showSnack(violence ? "Violence detected!" : "Analysis complete");
  }

  void _showAudioResult(String apiResponse) {
    Map<String, dynamic> data = jsonDecode(apiResponse);

    bool violence = data["violence"] ?? false;
    String audioResult = data["audio_result"] ?? "Unknown";
    String type = data["overall_violence_type"] ?? "N/A";

    String summary = violence
        ? "⚠️ VIOLENCE DETECTED (Audio)\n"
        : "✅ Normal Audio\n";

    summary += "Result: $audioResult\nType: $type\n";

    setState(() {
      detectionResult = summary;
    });

    _showSnack(violence ? "Violence detected in audio!" : "Audio analysis complete");
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Media Upload"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 60,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Media Upload",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Upload image or video for AI analysis",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                Card(
                  elevation: 5,
                  child: InkWell(
                    onTap: pickImage,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.green,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Upload Image",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                  elevation: 5,
                  child: InkWell(
                    onTap: pickVideo,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_file,
                          size: 60,
                          color: Colors.red,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Upload Video",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 5,
                  child: InkWell(
                    onTap: pickAudio,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.audiotrack, size: 60, color: Colors.orange),
                        SizedBox(height: 10),
                        Text("Upload Audio", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    detectionResult.isEmpty
                        ? "No Result Yet"
                        : detectionResult,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}