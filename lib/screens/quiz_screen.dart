import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Map<String, Object>> _questions = [
    {
      'question': 'What does CPU stand for?',
      'options': ['Central Processing Unit', 'Computer Power Unit', 'Control Panel Unit', 'Central Power Utility'],
      'answer': 'Central Processing Unit'
    },
    {
      'question': 'Which of the following is an input device?',
      'options': ['Monitor', 'Printer', 'Keyboard', 'Speaker'],
      'answer': 'Keyboard'
    },
    {
      'question': 'What is the function of RAM?',
      'options': ['Store permanent files', 'Process graphics', 'Provide temporary storage', 'Backup data'],
      'answer': 'Provide temporary storage'
    },
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  String _selectedAnswer = '';

  void _selectAnswer(String answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;

      if (answer == _questions[_currentQuestionIndex]['answer']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _answered = false;
      _selectedAnswer = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final List<String> options = List<String>.from(currentQuestion['options'] as List);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              currentQuestion['question'] as String,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ...options.map((option) => Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _answered
                    ? option == currentQuestion['answer']
                      ? Colors.green
                      : option == _selectedAnswer
                        ? Colors.red
                        : null
                    : null,
                ),
                onPressed: () => _selectAnswer(option),
                child: Text(option),
              ),
            )),
            const Spacer(),
            if (_answered)
              ElevatedButton(
                onPressed: _currentQuestionIndex < _questions.length - 1
                    ? _nextQuestion
                    : () => _showResultDialog(context),
                child: Text(_currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Finish'),
              )
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Text('Your score is $_score out of ${_questions.length}.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to the previous screen
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
