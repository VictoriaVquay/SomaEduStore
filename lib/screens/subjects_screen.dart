import 'package:flutter/material.dart';
import 'materials_screen.dart';

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(subject['name']),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MaterialsScreen(subject: subject),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
