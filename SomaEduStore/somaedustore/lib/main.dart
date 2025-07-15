import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

void main() {
  runApp(const SomaEduStoreApp());
}

class SomaEduStoreApp extends StatelessWidget {
  const SomaEduStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SomaEduStore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SubjectsScreen(),
    );
  }
}

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  final List<Map<String, dynamic>> subjects = const [
    {
      'name': 'Digital Literacy',
      'materials': [
        {'title': 'Computer Basics PDF', 'type': 'pdf'},
        {'title': 'Intro Video', 'type': 'video'},
        {'title': 'Quiz 1', 'type': 'quiz'},
      ],
    },
    {
      'name': 'Internet Safety',
      'materials': [
        {'title': 'Safety Guide PDF', 'type': 'pdf'},
        {'title': 'Safety Tips Video', 'type': 'video'},
      ],
    },
    {
      'name': 'Communication Tools',
      'materials': [
        {'title': 'Email Basics PDF', 'type': 'pdf'},
        {'title': 'Messaging Apps Video', 'type': 'video'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SomaEduStore'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return ListTile(
            title: Text(subject['name']),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MaterialsScreen(
                    subject: subject['name'],
                    materials: subject['materials'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MaterialsScreen extends StatelessWidget {
  final String subject;
  final List materials;

  const MaterialsScreen({
    super.key,
    required this.subject,
    required this.materials,
  });

  Future<void> downloadAndOpen(
    BuildContext context,
    String title,
    String type,
  ) async {
    // Example URLs for demonstration
    final urls = {
      'pdf':
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      'video':
          'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
      'quiz':
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', // Replace with actual quiz file
    };
    final url = urls[type] ?? urls['pdf'] ?? '';
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No download URL available.')),
      );
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/$title.${type == 'pdf'
              ? 'pdf'
              : type == 'video'
              ? 'mp4'
              : 'pdf'}';
      final file = File(filePath);

      if (!await file.exists()) {
        final dio = Dio();
        await dio.download(url, filePath);
      }

      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading/opening file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final material = materials[index];
          return ListTile(
            leading: Icon(
              material['type'] == 'pdf'
                  ? Icons.picture_as_pdf
                  : material['type'] == 'video'
                  ? Icons.video_library
                  : Icons.quiz,
            ),
            title: Text(material['title']),
            trailing: ElevatedButton(
              child: const Text('Download & Open'),
              onPressed: () {
                downloadAndOpen(context, material['title'], material['type']);
              },
            ),
          );
        },
      ),
    );
  }
}
