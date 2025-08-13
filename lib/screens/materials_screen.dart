import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'quiz_screen.dart';

class MaterialsScreen extends StatelessWidget {
  final String subject;
  final List materials;
  final Map<String, String> urls;

  const MaterialsScreen({
    super.key,
    required this.subject,
    required this.materials,
    required this.urls,
  });

  @override
  Widget build(BuildContext context) {
    return _MaterialsScreenState(
      subject: subject,
      materials: materials,
      urls: urls,
    );
  }
}

class _MaterialsScreenState extends StatefulWidget {
  final String subject;
  final List materials;
  final Map<String, String> urls;

  const _MaterialsScreenState({
    required this.subject,
    required this.materials,
    required this.urls,
  });

  @override
  State<_MaterialsScreenState> createState() => _MaterialsScreenStateState();
}

class _MaterialsScreenStateState extends State<_MaterialsScreenState> {
  late final Directory _cacheDir;

  @override
  void initState() {
    super.initState();
    _prepareCacheDir();
  }

  Future<void> _prepareCacheDir() async {
    _cacheDir = await getApplicationDocumentsDirectory();
  }

  Icon _getIcon(String type) {
    switch (type) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'video':
        return const Icon(Icons.video_library, color: Colors.deepPurple);
      case 'quiz':
        return const Icon(Icons.quiz, color: Colors.teal);
      default:
        return const Icon(Icons.insert_drive_file);
    }
  }

  Future<void> _openMaterial(String title, String type) async {
    final url = widget.urls[title];

    if (type == 'quiz') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QuizScreen()),
      );
      return;
    }

    if (url == null) {
      _showMessage("No URL found for $title");
      return;
    }

    final filename = url.split('/').last;
    final filePath = "${_cacheDir.path}/$filename";
    final file = File(filePath);

    try {
      if (!await file.exists()) {
        _showMessage("Downloading $title...");
        final response = await Dio().download(url, filePath);
        if (response.statusCode != 200) {
          _showMessage("Failed to download $title");
          return;
        }
      }

      await OpenFile.open(file.path);
    } catch (e) {
      _showMessage("Error opening $title: $e");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final materials = widget.materials;

    return Scaffold(
      appBar: AppBar(title: Text(widget.subject)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final material = materials[index];
          final title = material['title'];
          final type = material['type'];
          final url = widget.urls[title];
          final filename = url != null ? url.split('/').last : '';
          final filePath = "${_cacheDir.path}/$filename";
          final file = File(filePath);

          return FutureBuilder<bool>(
            future: file.exists(),
            builder: (context, snapshot) {
              final downloaded = snapshot.data ?? false;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: _getIcon(type),
                  title: Text(title),
                  subtitle: Text(
                    downloaded
                        ? "Available offline"
                        : "Tap to download and open",
                    style: TextStyle(
                      color: downloaded ? Colors.green : Colors.grey,
                    ),
                  ),
                  trailing: downloaded
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => _openMaterial(title, type),
                        ),
                  onTap: () => _openMaterial(title, type),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
