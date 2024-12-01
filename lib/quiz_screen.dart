import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  QuizScreen({required this.questions});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _feedback;

  void _answerQuestion(String userAnswer) {
    final correctAnswer = widget.questions[_currentQuestionIndex]['correct_answer'];

    setState(() {
      if (userAnswer == correctAnswer) {
        _score++;
        _feedback = "Correct!";
      } else {
        _feedback = "Incorrect! Correct answer: $correctAnswer";
      }

      // Move to the next question after a short delay
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _feedback = null;
          if (_currentQuestionIndex < widget.questions.length - 1) {
            _currentQuestionIndex++;
          } else {
            _showFinalScore();
          }
        });
      });
    });
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Quiz Completed!'),
        content: Text('Your final score is $_score/${widget.questions.length}.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Go back to the setup screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentQuestionIndex];
    final answers = [...currentQuestion['incorrect_answers'], currentQuestion['correct_answer']];
    answers.shuffle(); // Randomize answer order

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              currentQuestion['question'],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ...answers.map((answer) {
              return ElevatedButton(
                onPressed: () => _answerQuestion(answer),
                child: Text(answer),
              );
            }).toList(),
            Spacer(),
            if (_feedback != null)
              Text(
                _feedback!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            Text(
              'Score: $_score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
