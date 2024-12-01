import 'dart:async'; // For Timer
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
  int _timeRemaining = 15; // Timer starts with 15 seconds
  Timer? _timer;
  List<String> _userAnswers = [];
  List<String> _correctAnswers = [];
  List<bool> _answeredCorrectly = [];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timeRemaining = 15;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        // Timer expired
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    _timer?.cancel();
    setState(() {
      _feedback = "Time's up! Correct answer: ${widget.questions[_currentQuestionIndex]['correct_answer']}";
      _userAnswers.add('Time\'s up');
      _correctAnswers.add(widget.questions[_currentQuestionIndex]['correct_answer']);
      _answeredCorrectly.add(false);
    });

    // Move to the next question after a short delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _feedback = null;
        if (_currentQuestionIndex < widget.questions.length - 1) {
          _currentQuestionIndex++;
          _startTimer();
        } else {
          _showSummary();
        }
      });
    });
  }

  void _answerQuestion(String userAnswer) {
    _timer?.cancel(); // Stop the timer once the user answers
    final correctAnswer = widget.questions[_currentQuestionIndex]['correct_answer'];

    setState(() {
      _userAnswers.add(userAnswer);
      _correctAnswers.add(correctAnswer);
      _answeredCorrectly.add(userAnswer == correctAnswer);

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
            _startTimer();
          } else {
            _showSummary();
          }
        });
      });
    });
  }

  void _showSummary() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Quiz Completed!'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your final score is $_score/${widget.questions.length}.'),
            SizedBox(height: 20),
            Text('Correct Answers:'),
            ...List.generate(widget.questions.length, (index) {
              return Text(
                '${widget.questions[index]['question']} \nYour Answer: ${_userAnswers[index]} \nCorrect Answer: ${_correctAnswers[index]} \n\n',
                style: TextStyle(color: _answeredCorrectly[index] ? Colors.green : Colors.red),
              );
            }),
            SizedBox(height: 20),
            Text('Missed Questions:'),
            ...List.generate(widget.questions.length, (index) {
              if (!_answeredCorrectly[index]) {
                return Text(
                  '${widget.questions[index]['question']} \nCorrect Answer: ${_correctAnswers[index]} \n\n',
                  style: TextStyle(color: Colors.red),
                );
              }
              return Container(); // Empty container for answered questions
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _retakeQuiz();
            },
            child: Text('Retake Quiz'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Go back to the setup screen
            },
            child: Text('Return to Setup'),
          ),
        ],
      ),
    );
  }

  void _retakeQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _feedback = null;
      _timeRemaining = 15;
      _userAnswers.clear();
      _correctAnswers.clear();
      _answeredCorrectly.clear();
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentQuestionIndex];
    final answers = [...currentQuestion['incorrect_answers'], currentQuestion['correct_answer']];
    answers.shuffle(); // Randomize answer order

    // Calculate progress as a fraction of questions answered
    double progress = (_currentQuestionIndex + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              minHeight: 8.0,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            SizedBox(height: 16.0),
            
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $_score',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Time: $_timeRemaining',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _timeRemaining <= 5 ? Colors.red : Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
