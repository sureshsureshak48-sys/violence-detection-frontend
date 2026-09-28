import 'package:flutter/material.dart';
import 'services/evidence_api.dart';
import 'services/api_service.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  final EvidenceApi evidenceApi = EvidenceApi();
  List allEvidence = [];
  List filteredEvidence = [];
  String activeFilter = "ALL";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEvidence();
  }

  Future<void> loadEvidence() async {
    try {
      final data = await evidenceApi.getEvidence();
      setState(() {
        allEvidence = data.reversed.toList();
        _applyFilter();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print("Error loading evidence gallery: $e");
    }
  }

  void _applyFilter() {
    setState(() {
      if (activeFilter == "ALL") {
        filteredEvidence = allEvidence;
      } else {
        filteredEvidence = allEvidence
            .where((e) => (e["fileType"] ?? "").toString().toUpperCase() == activeFilter)
            .toList();
      }
    });
  }

  Future<void> _deleteEvidence(int id) async {
    try {
      bool success = await evidenceApi.deleteEvidence(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evidence deleted")),
        );
        loadEvidence();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete evidence")),
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
        title: const Text("Delete Evidence"),
        content: const Text("Are you sure you want to delete this evidence?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvidence(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _buildUrl(String filePath) {
    String filename = filePath.replaceAll("\\", "/");

    if (filename.contains("evidence/")) {
      filename = filename.split("evidence/").last;
    }

    return "${ApiService.flaskUrl}/evidence/$filename";
  }

  void _previewImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text("Photo Evidence"),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text("Error loading image asset"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previewVideo(String url) {
    VideoPlayerController controller = VideoPlayerController.networkUrl(Uri.parse(url));
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (!controller.value.isInitialized) {
              controller.initialize().then((_) => setDialogState(() {}));
            }
            return AlertDialog(
              title: const Text("Video Clip Evidence"),
              content: controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    )
                  : const SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    ),
              actions: [
                if (controller.value.isInitialized)
                  IconButton(
                    icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      setDialogState(() {
                        controller.value.isPlaying ? controller.pause() : controller.play();
                      });
                    },
                  ),
                TextButton(
                  onPressed: () {
                    controller.dispose();
                    Navigator.pop(context);
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _previewAudio(String url) {
    AudioPlayer player = AudioPlayer();
    bool isPlaying = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Audio Feed Evidence"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.audiotrack, size: 50, color: Colors.blue),
                  const SizedBox(height: 12),
                  const Text("Trimmed audio recording from incident."),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                    iconSize: 48,
                    color: Colors.blue,
                    onPressed: () async {
                      if (isPlaying) {
                        await player.pause();
                      } else {
                        await player.play(UrlSource(url));
                      }
                      setDialogState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    player.dispose();
                    Navigator.pop(context);
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Evidence Vault"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => loading = true);
              loadEvidence();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- FILTER CATEGORY ROW ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: [
                _filterChip("ALL", "📂 All Assets"),
                _filterChip("IMAGE", "📷 Photos"),
                _filterChip("VIDEO", "🎬 Videos"),
                _filterChip("AUDIO", "🔊 Audio Feeds"),
              ],
            ),
          ),

          // --- GALLERY VIEW ---
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredEvidence.isEmpty
                    ? const Center(child: Text("No media assets found in this category."))
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: filteredEvidence.length,
                        itemBuilder: (context, index) {
                          final item = filteredEvidence[index];
                          final String fileType = item["fileType"] ?? "IMAGE";
                          final String rawPath = item["filePath"] ?? "";
                          final String url = _buildUrl(rawPath);
                          final String filename = rawPath.split('/').last.split('\\').last;

                          return Card(
                            elevation: 3,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                if (fileType == "IMAGE") {
                                  _previewImage(url);
                                } else if (fileType == "VIDEO") {
                                  _previewVideo(url);
                                } else if (fileType == "AUDIO") {
                                  _previewAudio(url);
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: Colors.grey[200],
                                      child: fileType == "IMAGE"
                                          ? Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stack) =>
                                                  const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                            )
                                          : Icon(
                                              fileType == "VIDEO"
                                                  ? Icons.play_circle_fill
                                                  : Icons.mic,
                                              size: 48,
                                              color: fileType == "VIDEO" ? Colors.red : Colors.blue,
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          filename,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              fileType,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 10,
                                              ),
                                            ),
                                            if (item["incidentId"] != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  "Incident #${item['incidentId']}",
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
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

  Widget _filterChip(String filterKey, String label) {
    final bool isSelected = activeFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.blue.withOpacity(0.2),
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[800] : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (val) {
          if (val) {
            setState(() {
              activeFilter = filterKey;
              _applyFilter();
            });
          }
        },
      ),
    );
  }
}