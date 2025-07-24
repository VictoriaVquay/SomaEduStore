import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'quiz_screen.dart'; // Make sure this file exists

class MaterialsScreen extends StatelessWidget {
  final Map<String, dynamic> subject;

  MaterialsScreen({super.key, required this.subject});

  final Map<String, String> urls = {
    'Computer Basics PDF': 'https://able2work.org/wp-content/uploads/2014/08/Basic_Digital_Literacy_Course.pdf',
    'Intro Video': 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
    'Quiz 1': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    'Safety Guide PDF': 'https://www.cisa.gov/sites/default/files/publications/Cybersecurity%20Guide%20for%20Small%20Businesses_508c.pdf',
    'Safety Tips Video': 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
    'Email Basics PDF': 'https://edu.gcfglobal.org/en/internetbasics/what-is-email/1/',
    'Messaging Apps Video': 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
  };

  void _openMaterial(BuildContext context, String title, String type) async {
    if (type == 'quiz') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QuizScreen()),
      );
    } else {
      final url = urls[title];
      if (url != null && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $title...')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $title')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> materials = subject['materials'];

    return Scaffold(
      appBar: AppBar(title: Text(subject['name'])),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final material = materials[index];
          return Card(
            child: ListTile(
              title: Text(material['title']),
              subtitle: Text('Type: ${material['type']}'),
              trailing: ElevatedButton(
                onPressed: () => _openMaterial(context, material['title'], material['type']),
                child: Text(material['type'] == 'quiz' ? 'Start' : 'Open'),
              ),
            ),
          );
        },
      ),
    );
  }
}
