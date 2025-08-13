import 'package:flutter/material.dart';
import '../main.dart' show themeNotifier, UserStore;
import 'materials_screen.dart';
import 'login_screen.dart';

class SubjectsScreen extends StatelessWidget {
  SubjectsScreen({super.key});

  final List<Map<String, dynamic>> subjects = [
    {
      'name': 'Computer Basics',
      'materials': [
        {'title': 'Computer Basics PDF', 'type': 'pdf'},
        {'title': 'Intro Video', 'type': 'video'},
        {'title': 'Quiz 1', 'type': 'quiz'},
      ],
    },
    {
      'name': 'Online Safety',
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

  final Map<String, String> materialUrls = {
    'Computer Basics PDF':
        'https://able2work.org/wp-content/uploads/2014/08/Basic_Digital_Literacy_Course.pdf',
    'Intro Video':
        'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
    'Quiz 1':
        'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    'Safety Guide PDF':
        'https://www.cisa.gov/sites/default/files/publications/Cybersecurity%20Guide%20for%20Small%20Businesses_508c.pdf',
    'Safety Tips Video':
        'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
    'Email Basics PDF':
        'https://file-examples.com/wp-content/uploads/2017/10/file-sample_150kB.pdf',
    'Messaging Apps Video':
        'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SomaEduStore'),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
            onPressed: () async {
              await UserStore.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                subject['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF3BAFDA),
                size: 28,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MaterialsScreen(
                      subject: subject['name'],
                      materials: subject['materials'],
                      urls: materialUrls,
                    ),
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

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        themeNotifier.value == ThemeMode.dark
            ? Icons.dark_mode
            : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
      tooltip: 'Toggle Theme',
      onPressed: () {
        themeNotifier.value = themeNotifier.value == ThemeMode.dark
            ? ThemeMode.light
            : ThemeMode.dark;
      },
    );
  }
}
