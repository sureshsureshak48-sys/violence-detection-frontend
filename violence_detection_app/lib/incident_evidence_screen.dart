import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/evidence_api.dart';
import 'services/api_service.dart';

class IncidentEvidenceScreen extends StatefulWidget {
  final int incidentId;
  final String incidentType;
  final String createdAt;

  const IncidentEvidenceScreen({
    super.key,
    required this.incidentId,
    required this.incidentType,
    required this.createdAt,
  });

  @override
  State<IncidentEvidenceScreen> createState() => _IncidentEvidenceScreenState();
}

class _IncidentEvidenceScreenState extends State<IncidentEvidenceScreen> {
  final EvidenceApi evidenceApi = EvidenceApi();
  List evidenceList = [];
  bool loading = true;

  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    loadEvidence();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> loadEvidence() async {
    try {
      final data = await evidenceApi.getEvidenceByIncident(widget.incidentId);
      setState(() {
        evidenceList = data;
        loading = false;
      });

      // Initialize video player if a VIDEO evidence exists
      for (var e in data) {
        if (e["fileType"] == "VIDEO") {
          String videoUrl = _buildUrl(e["filePath"]);
          _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
            ..initialize().then((_) {
              setState(() {});
            });
          break;
        }
      }
    } catch (e) {
      setState(() => loading = false);
      print("Error loading evidence: $e");
    }
  }

  String _buildUrl(String filePath) {
    // Convert "evidence/clip_1.2.mp4" -> "http://baseUrl/evidence/clip_1.2.mp4"
    String filename = filePath.replaceAll("\\", "/");
    String finalUrl = "";
    if (filename.startsWith("evidence/")) {
      filename = filename.replaceFirst("evidence/", "");
      finalUrl = "${ApiService.flaskUrl}/evidence/$filename";
    } else {
      finalUrl = "${ApiService.baseUrl}/$filename";
    }
    print("LOADING EVIDENCE URL: $finalUrl");
    return finalUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Evidence: ${widget.incidentType}"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : evidenceList.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      "No evidence found for this incident.\n\nNote: If this is an OLD incident from before the bug fix, it is corrupted. Please upload a NEW video to test!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- DATE & TIME HEADER ---
                      Card(
                        color: Colors.blue.shade50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.blue.shade200, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Incident Time: ${widget.createdAt.replaceAll('T', ' ').split('.')[0]}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- ANNOTATED IMAGE SECTION ---
                      _buildSectionTitle("📸 Annotated Photo (Object Detection)"),
                      const SizedBox(height: 8),
                      _buildImageEvidence(),
                      const SizedBox(height: 24),

                      // --- VIDEO CLIP SECTION ---
                      _buildSectionTitle("🎬 Violence Video Clip (5 sec)"),
                      const SizedBox(height: 8),
                      _buildVideoEvidence(),
                      const SizedBox(height: 24),

                      // --- AUDIO CLIP SECTION ---
                      _buildSectionTitle("🔊 Audio Evidence (5 sec)"),
                      const SizedBox(height: 8),
                      _buildAudioEvidence(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildImageEvidence() {
    final imageEvidence = evidenceList
        .where((e) => e["fileType"] == "IMAGE")
        .toList();

    if (imageEvidence.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("No annotated image available."),
        ),
      );
    }

    String imageUrl = _buildUrl(imageEvidence.first["filePath"]);

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text("Failed to load image")),
          );
        },
      ),
    );
  }

  Widget _buildVideoEvidence() {
    final videoEvidence = evidenceList
        .where((e) => e["fileType"] == "VIDEO")
        .toList();

    if (videoEvidence.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("No video clip available."),
        ),
      );
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Card(
        child: SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 40,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _videoController!.value.isPlaying
                          ? _videoController!.pause()
                          : _videoController!.play();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.replay, size: 30),
                  onPressed: () {
                    _videoController!.seekTo(Duration.zero);
                    _videoController!.play();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioEvidence() {
    final audioEvidence = evidenceList
        .where((e) => e["fileType"] == "AUDIO")
        .toList();

    if (audioEvidence.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("No audio clip available."),
        ),
      );
    }

    String audioUrl = _buildUrl(audioEvidence.first["filePath"]);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isAudioPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 48,
                color: Colors.blue,
              ),
              onPressed: () async {
                if (_isAudioPlaying) {
                  await _audioPlayer.pause();
                } else {
                  await _audioPlayer.play(UrlSource(audioUrl));
                }
                setState(() {
                  _isAudioPlaying = !_isAudioPlaying;
                });
              },
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Audio Evidence",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Tap play to hear the audio from the incident.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
