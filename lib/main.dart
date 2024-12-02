import 'package:flutter/material.dart';
import 'quiz_screen.dart'; // Import the QuizScreen
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: QuizSetupScreen(),
    );
  }
}

class QuizSetupScreen extends StatefulWidget {
  @override
  _QuizSetupScreenState createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int _numberOfQuestions = 5;
  String? _selectedCategory;
  String? _selectedDifficulty;
  String? _selectedType;

  List<Map<String, String>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _categories = (data['trivia_categories'] as List)
    .map<Map<String, String>>((category) => {
          'id': category['id'].toString(),
          'name': category['name'] as String,
        })
    .toList();

      });
    }
  }

  final List<String> _difficulties = ['easy', 'medium', 'hard'];
  final List<String> _questionTypes = ['multiple', 'boolean'];

  void _startQuiz() async {
    // Fetch questions from Open Trivia Database
    final url = Uri.parse(
      'https://opentdb.com/api.php?amount=$_numberOfQuestions&category=$_selectedCategory&difficulty=$_selectedDifficulty&type=$_selectedType',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final questions = (data['results'] as List).map((q) => {
            'question': q['question'],
            'correct_answer': q['correct_answer'],
            'incorrect_answers': q['incorrect_answers'],
          }).toList();

      // Navigate to the QuizScreen with fetched questions
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(questions: questions),
        ),
      );
    } else {
      print('Failed to fetch questions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Number of Questions', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: _numberOfQuestions,
              items: [5, 10, 15].map((num) {
                return DropdownMenuItem(
                  value: num,
                  child: Text(num.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _numberOfQuestions = value!;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text('Select Category', style: TextStyle(fontWeight: FontWeight.bold)),
            _categories.isEmpty
                ? CircularProgressIndicator()
                : DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category['id'],
                        child: Text(category['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
            SizedBox(height: 16.0),
            Text('Select Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedDifficulty,
              items: _difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text('Select Question Type', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedType,
              items: _questionTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type == 'multiple' ? 'Multiple Choice' : 'True/False'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _selectedCategory == null || _selectedDifficulty == null || _selectedType == null
                  ? null
                  : _startQuiz,
              child: Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
