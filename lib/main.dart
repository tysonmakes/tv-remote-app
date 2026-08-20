import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() => runApp(const TVRemoteApp());

class TVRemoteApp extends StatelessWidget {
  const TVRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const RemoteScreen(),
    );
  }
}

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  final TextEditingController _ipController = TextEditingController(text: "192.168.1.100");
  Socket? _socket;
  bool _connected = false;

  void _connect() async {
    try {
      _socket = await Socket.connect(_ipController.text.trim(), 5555, timeout: const Duration(seconds: 5));
      setState(() => _connected = true);
      _showMsg("Connected to TV!");
    } catch (e) {
      _showMsg("Failed to connect: $e");
    }
  }

  void _sendKey(String keycode) {
    if (!_connected || _socket == null) {
      _showMsg("Connect to TV first!");
      return;
    }
    _socket!.write('shell:input keyevent $keycode\n');
  }

  void _pickAndSideload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );

    if (result != null && result.files.single.path != null) {
      _showMsg("Selected APK: ${result.files.single.name}");
    }
  }

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TV ADB Remote")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(labelText: "TV IP Address"),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _connect,
                  child: Text(_connected ? "Connected" : "Connect"),
                )
              ],
            ),
            const SizedBox(height: 30),
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.arrow_drop_up),
              onPressed: () => _sendKey("KEYCODE_DPAD_UP"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () => _sendKey("KEYCODE_DPAD_LEFT"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(20)),
                  onPressed: () => _sendKey("KEYCODE_DPAD_CENTER"),
                  child: const Text("OK"),
                ),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () => _sendKey("KEYCODE_DPAD_RIGHT"),
                ),
              ],
            ),
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.arrow_drop_down),
              onPressed: () => _sendKey("KEYCODE_DPAD_DOWN"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _sendKey("KEYCODE_BACK"),
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: () => _sendKey("KEYCODE_HOME"),
                  child: const Text("Home"),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.file_upload),
              label: const Text("Sideload APK File"),
              onPressed: _connected ? _pickAndSideload : null,
            )
          ],
        ),
      ),
    );
  }
}

