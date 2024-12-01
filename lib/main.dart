import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizSetupScreen extends StatefulWidget {
  @override
  _QuizSetupScreenState createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  // User selections
  int _numberOfQuestions = 5;
  String? _selectedCategory;
  String? _selectedDifficulty;
  String? _selectedType;

  // Category list
  List<Map<String, String>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories on screen load
  }

  // Fetch trivia categories from the API
  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _categories = (data['trivia_categories'] as List)
            .map((category) => {
                  'id': category['id'].toString(),
                  'name': category['name'],
                })
            .toList();
      });
    } else {
      // Handle error
      print("Failed to load categories");
    }
  }

  // List of difficulty levels
  final List<String> _difficulties = ['easy', 'medium', 'hard'];

  // List of question types
  final List<String> _questionTypes = ['multiple', 'boolean'];

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
            // Number of Questions
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

            // Category Selection
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

            // Difficulty Selection
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

            // Question Type Selection
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

            // Submit Button
            ElevatedButton(
              onPressed: _selectedCategory == null || _selectedDifficulty == null || _selectedType == null
                  ? null
                  : () {
                      _fetchQuizQuestions();
                    },
              child: Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch quiz questions based on user selections
  Future<void> _fetchQuizQuestions() async {
    final url = Uri.parse(
      'https://opentdb.com/api.php?amount=$_numberOfQuestions&category=$_selectedCategory&difficulty=$_selectedDifficulty&type=$_selectedType',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data); // Replace this with navigation to the quiz screen
    } else {
      print('Failed to fetch questions');
    }
  }
}
