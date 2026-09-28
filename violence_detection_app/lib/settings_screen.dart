import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Detection Thresholds
  double _violenceSensitivity = 0.75;
  double _x3dWeight = 0.5;
  bool _nightModeSensitivity = true;

  // Camera Settings
  String _cameraResolution = "224x224";
  double _frameStride = 16.0;

  // Notification Preferences
  double _alertRadius = 3.0;
  bool _pushNotifications = true;
  bool _soundAlerts = true;
  bool _emailReports = false;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _violenceSensitivity = prefs.getDouble('violenceSensitivity') ?? 0.75;
      _x3dWeight = prefs.getDouble('x3dWeight') ?? 0.5;
      _nightModeSensitivity = prefs.getBool('nightModeSensitivity') ?? true;
      _cameraResolution = prefs.getString('cameraResolution') ?? "224x224";
      _frameStride = prefs.getDouble('frameStride') ?? 16.0;
      _alertRadius = prefs.getDouble('alertRadius') ?? 3.0;
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _soundAlerts = prefs.getBool('soundAlerts') ?? true;
      _emailReports = prefs.getBool('emailReports') ?? false;
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('violenceSensitivity', _violenceSensitivity);
    await prefs.setDouble('x3dWeight', _x3dWeight);
    await prefs.setBool('nightModeSensitivity', _nightModeSensitivity);
    await prefs.setString('cameraResolution', _cameraResolution);
    await prefs.setDouble('frameStride', _frameStride);
    await prefs.setDouble('alertRadius', _alertRadius);
    await prefs.setBool('pushNotifications', _pushNotifications);
    await prefs.setBool('soundAlerts', _soundAlerts);
    await prefs.setBool('emailReports', _emailReports);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Settings saved successfully!"),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("System Settings"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: DETECTION THRESHOLDS ---
                  _buildSectionHeader("🧠 Detection Thresholds"),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text("Violence Sensitivity"),
                            subtitle: Text("${(_violenceSensitivity * 100).round()}%"),
                            trailing: SizedBox(
                              width: 150,
                              child: Slider(
                                value: _violenceSensitivity,
                                min: 0.1,
                                max: 1.0,
                                onChanged: (val) {
                                  setState(() => _violenceSensitivity = val);
                                },
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text("X3D Action Weight"),
                            subtitle: Text("${(_x3dWeight * 100).round()}%"),
                            trailing: SizedBox(
                              width: 150,
                              child: Slider(
                                value: _x3dWeight,
                                min: 0.1,
                                max: 1.0,
                                onChanged: (val) {
                                  setState(() => _x3dWeight = val);
                                },
                              ),
                            ),
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text("Night/Low-Light Enhancement"),
                            subtitle: const Text("Lower detection thresholds in night environment"),
                            value: _nightModeSensitivity,
                            onChanged: (val) {
                              setState(() => _nightModeSensitivity = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- SECTION 2: CAMERA SETTINGS ---
                  _buildSectionHeader("📷 Camera Settings"),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text("Inference Resolution"),
                            subtitle: const Text("Frame size processed by AI model"),
                            trailing: DropdownButton<String>(
                              value: _cameraResolution,
                              items: ["224x224", "320x320", "640x640"].map((String r) {
                                return DropdownMenuItem<String>(
                                  value: r,
                                  child: Text(r),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _cameraResolution = val);
                                }
                              },
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text("Frame Sampling Stride"),
                            subtitle: Text("Process every ${_frameStride.round()} frames"),
                            trailing: SizedBox(
                              width: 150,
                              child: Slider(
                                value: _frameStride,
                                min: 4,
                                max: 32,
                                divisions: 7,
                                onChanged: (val) {
                                  setState(() => _frameStride = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- SECTION 3: NOTIFICATION PREFERENCES ---
                  _buildSectionHeader("🔔 Notification Preferences"),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text("Alert Distance Radius"),
                            subtitle: Text("${_alertRadius.toStringAsFixed(1)} km"),
                            trailing: SizedBox(
                              width: 150,
                              child: Slider(
                                value: _alertRadius,
                                min: 1.0,
                                max: 10.0,
                                onChanged: (val) {
                                  setState(() => _alertRadius = val);
                                },
                              ),
                            ),
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text("Push Notifications"),
                            subtitle: const Text("FCM alerts when incident approved"),
                            value: _pushNotifications,
                            onChanged: (val) {
                              setState(() => _pushNotifications = val);
                            },
                          ),

                          const Divider(),
                          SwitchListTile(
                            title: const Text("Daily Summary Email"),
                            subtitle: const Text("Export report logs automatically at midnight"),
                            value: _emailReports,
                            onChanged: (val) {
                              setState(() => _emailReports = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- SAVE BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        "Save Configurations",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
