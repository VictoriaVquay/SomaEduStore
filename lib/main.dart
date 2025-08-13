import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import
import 'package:flutter/foundation.dart'; // Add this import
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// SomaEduStore: A simple educational app for digital literacy, internet safety, and communication tools.
/// This app allows users to view subjects, download materials, and open them directly from the app.
/// It includes features for downloading PDFs, videos, and quizzes, and handles file management using Dio and OpenFile packages.
/// This app is designed to be user-friendly and educational, providing resources for students to enhance their digital skills.

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) =>
          SomaEduStoreApp(themeMode: mode), // <-- FIXED
    ),
  );
}

class SomaEduStoreApp extends StatelessWidget {
  final ThemeMode themeMode;
  const SomaEduStoreApp({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SomaEduStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF3BAFDA),
          onPrimary: Colors.white,
          secondary: Color(0xFF4CAF50),
          onSecondary: Colors.white,
          error: Color(0xFFF4A261),
          onError: Colors.white,
          surface: Color(0xFFE8F0F2),
          onSurface: Color(0xFF5F6B73),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        cardColor: const Color(0xFFE8F0F2),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF2D2D2D)),
          bodyMedium: TextStyle(color: Color(0xFF5F6B73)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF5F6B73)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3BAFDA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3BAFDA), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3BAFDA),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF3BAFDA)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE8F0F2),
          foregroundColor: Color(0xFF2D2D2D),
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF3BAFDA),
          onPrimary: Colors.black,
          secondary: Color(0xFF4CAF50),
          onSecondary: Colors.black,
          error: Color(0xFFF4A261),
          onError: Colors.black,
          surface: Color(0xFF23272A),
          onSurface: Color(0xFFF5F7FA),
        ),
        scaffoldBackgroundColor: const Color(0xFF181A1B),
        cardColor: const Color(0xFF23272A),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFF5F7FA)),
          bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
        ),
        // ...other dark theme settings...
      ),
      themeMode: themeMode,
      home: const SignupScreen(),
    );
  }
}

// Simple in-memory user store for demo
class UserStore {
  static Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  static Future<Map<String, String?>> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('email'),
      'password': prefs.getString('password'),
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        actions: const [ThemeToggleButton()],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (val) => email = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Enter password';
                  }
                  if (val.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(val)) {
                    return 'Include at least one uppercase letter';
                  }
                  if (!RegExp(r'[a-z]').hasMatch(val)) {
                    return 'Include at least one lowercase letter';
                  }
                  if (!RegExp(r'\d').hasMatch(val)) {
                    return 'Include at least one number';
                  }
                  if (!RegExp(r'[!@#\$&*~_.,;:<>?%^()-]').hasMatch(val)) {
                    return 'Include at least one special character';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Sign Up'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await UserStore.saveCredentials(email, password);
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
              TextButton(
                child: const Text('Already have an account? Login'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool rememberMe = false; // Add this line

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: const [ThemeToggleButton()],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (val) => email = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 16), // Add spacing between fields
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 12), // Spacing before Remember Me
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (val) {
                      setState(() {
                        rememberMe = val ?? false;
                      });
                    },
                  ),
                  const Text('Remember Me'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Login'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final creds = await UserStore.loadCredentials();
                    if (email == creds['email'] &&
                        password == creds['password']) {
                      if (!context.mounted) return;
                      // Optionally, save rememberMe state here
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubjectsScreen(),
                        ),
                      );
                    } else {
                      setState(() {
                        error = 'Invalid credentials';
                      });
                    }
                  }
                },
              ),
              TextButton(
                child: const Text('No account? Sign Up'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
      backgroundColor: const Color(0xFFF5F7FA), // Soft bluish-gray
      appBar: AppBar(
        title: const ReflectedTitle(text: 'SomaEduStore'),
        centerTitle: true,
        backgroundColor: const Color(0xFFE8F0F2), // Section background
        actions: [
          ThemeToggleButton(),
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
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Card(
            color: const Color(0xFFE8F0F2), // Section background
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            child: ListTile(
              title: Text(
                subject['name'], // Already uses correct titles: Digital Literacy, Internet Safety, Communication Tools
                style: const TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF3BAFDA), // Accent color
              ),
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
            ),
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

  static const Map<String, String> urls = {
    'Computer Basics PDF':
        'https://able2work.org/wp-content/uploads/2014/08/Basic_Digital_Literacy_Course.pdf',
    'Intro Video': 'https://www.youtube.com/watch?v=Qc8RJdTJpX4',
    'Quiz 1': 'https://www.proprofs.com/quiz-school/story.php?title=NTc3OTU0',
    'Safety Guide PDF':
        'https://www.kaspersky.com/resource-center/preemptive-safety/top-10-preemptive-safety-rules-and-what-not-to-do-online',
    'Safety Tips Video': 'https://www.youtube.com/watch?v=aO858HyFbKI',
    'Email Basics PDF':
        'https://www.ncccofoundation.org/wp-content/uploads/2025/04/Email-Basics-NCCCO-Foundation-Computer-Literacy.pdf',
    'Messaging Apps Video': 'https://www.youtube.com/watch?v=ELioaGg4WOY',
  };

  Future<void> downloadAndOpen(
    BuildContext context,
    String title,
    String type,
  ) async {
    final url = urls[title] ?? '';
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No download URL available.')),
      );
      return;
    }

    // Always open in browser on web
    if (kIsWeb ||
        url.contains('youtube.com') ||
        url.contains('proprofs.com') ||
        url.contains('kaspersky.com')) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch URL.')));
      }
      return;
    }

    // Otherwise, download and open (PDFs)
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ext = type == 'pdf' ? 'pdf' : 'file';
      final safeTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '_');
      final filePath = '${dir.path}/$safeTitle.$ext';
      final file = File(filePath);

      if (!await file.exists()) {
        final dio = Dio();
        await dio.download(url, filePath);
      }

      await OpenFile.open(filePath);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading/opening file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ReflectedTitle(text: subject),
        centerTitle: true,
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

class ReflectedTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  const ReflectedTitle({super.key, required this.text, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            color:
                Theme.of(context).appBarTheme.foregroundColor ??
                const Color(0xFF2D2D2D),
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationX(3.1416),
          child: Opacity(
            opacity: 0.25,
            child: Text(
              text,
              style: TextStyle(
                color:
                    Theme.of(context).appBarTheme.foregroundColor ??
                    const Color(0xFF2D2D2D),
                fontWeight: FontWeight.bold,
                fontSize: fontSize * 0.8,
              ),
            ),
          ),
        ),
      ],
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
