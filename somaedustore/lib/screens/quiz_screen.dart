import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

final List<QuizQuestion> sampleQuiz = [
  QuizQuestion(
    question: 'What does CPU stand for?',
    options: ['Central Processing Unit', 'Computer Primary Unit', 'Central Program Unit'],
    correctAnswerIndex: 0,
  ),
  QuizQuestion(
    question: 'Which one is an input device?',
    options: ['Monitor', 'Mouse', 'Speaker'],
    correctAnswerIndex: 1,
  ),
];

class QuizScreen extends StatefulWidget {
  final String userName;
  const QuizScreen({super.key, required this.userName});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  int score = 0;

  void submitAnswer(int selectedIndex) {
    final question = sampleQuiz[currentIndex];
    if (selectedIndex == question.correctAnswerIndex) {
      score++;
    }
    if (currentIndex < sampleQuiz.length - 1) {
      setState(() => currentIndex++);
    } else {
      saveResultToSupabase();
    }
  }

  void saveResultToSupabase() async {
    final client = Supabase.instance.client;
    await client.from('quiz_results').insert({
      'name': widget.userName,
      'score': score,
      'total': sampleQuiz.length,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Quiz Completed'),
          content: Text('Score: $score / ${sampleQuiz.length}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = sampleQuiz[currentIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / sampleQuiz.length,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Q${currentIndex + 1}: ${question.question}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(question.options.length, (i) {
              return ElevatedButton(
                onPressed: () => submitAnswer(i),
                child: Text(question.options[i]),
              );
            }),
          ],
        ),
      ),
    );
  }
}
