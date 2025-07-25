import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

/// SomaEduStore: A simple educational app for digital literacy, internet safety, and communication tools.
/// This app allows users to view subjects, download materials, and open them directly from the app.
/// It includes features for downloading PDFs, videos, and quizzes, and handles file management using Dio and OpenFile packages.
/// This app is designed to be user-friendly and educational, providing resources for students to enhance their digital skills.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    final urls = {
      // Digital Literacy
      'Computer Basics PDF':
          'https://able2work.org/wp-content/uploads/2014/08/Basic_Digital_Literacy_Course.pdf', // Basic digital literacy PDF
      'Intro Video':
          'https://www.youtube.com/watch?v=Qc8RJdTJpX4&list=PL3bOBGhOIybBdhkGQbHn-W-sYudXVLuVn', // LearnFree intro to computers
      'Quiz 1':
          'https://www.proprofs.com/quiz-school/story.php?title=NTc3OTU0', // External online quiz
      // Internet Safety
      'Safety Guide PDF':
          'https://www.kaspersky.com/resource-center/preemptive-safety/top-10-preemptive-safety-rules-and-what-not-to-do-online',
      'Safety Tips Video':
          'https://www.youtube.com/watch?v=aO858HyFbKI', // Internet safety tips video
      // Communication Tools
      'Email Basics PDF':
          'https://www.ncccofoundation.org/wp-content/uploads/2025/04/Email-Basics-NCCCO-Foundation-Computer-Literacy.pdf', // Email basics PDF
      'Messaging Apps Video':
          'https://www.youtube.com/watch?v=ELioaGg4WOY', // How messaging apps work
    };

    final url = urls[title] ?? '';
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

      //await OpenFile.open(filePath);
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
