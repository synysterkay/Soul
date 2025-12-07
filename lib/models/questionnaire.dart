import 'package:flutter/material.dart';

class Question {
  final String question;
  final List<String> options;

  Question({required this.question, required this.options});
}

class Questionnaire {
  int _currentQuestionIndex = 0;
  final List<String> _answers = [];
  List<Question> _questions = [];

  int get currentQuestionIndex => _currentQuestionIndex;

  List<Question> getQuestions(BuildContext context) {
    return [
      Question(
        question: "How are you feeling right now?",
        options: [
          "Energized & Ready",
          "Relaxed & Calm",
          "Stressed & Need Break",
          "Excited & Adventurous",
          "Tired & Low Energy",
          "Romantic & Intimate",
        ],
      ),
      Question(
        question: "What's your mood for the date?",
        options: [
          "Fun & Playful",
          "Deep & Meaningful",
          "Spontaneous & Wild",
          "Cozy & Comfortable",
          "Romantic & Passionate",
        ],
      ),
      Question(
        question: "What kind of activity appeals to you?",
        options: [
          "Active & Outdoors",
          "Relaxing & Peaceful",
          "Cultural & Educational",
          "Dining & Tasting",
          "Entertainment & Shows",
        ],
      ),
      Question(
        question: "How social are you feeling?",
        options: [
          "Very social, love crowds",
          "Prefer intimate settings",
          "Just the two of us",
        ],
      ),
      Question(
        question: "What pace sounds good?",
        options: [
          "Fast-paced & Exciting",
          "Slow & Leisurely",
          "Balanced mix of both",
        ],
      ),
      Question(
        question: "What atmosphere do you prefer?",
        options: [
          "Elegant & Sophisticated",
          "Casual & Laid-back",
          "Quirky & Unique",
          "Natural & Outdoorsy",
        ],
      ),
      Question(
        question: "How adventurous are you feeling?",
        options: [
          "Try something completely new",
          "Mix of familiar and new",
          "Stick to what we know",
        ],
      ),
      Question(
        question: "What time of day works best?",
        options: [
          "Morning/Brunch",
          "Afternoon",
          "Evening/Dinner",
          "Night/Late",
        ],
      ),
    ];
  }

  double get progress =>
      _questions.isEmpty ? 0 : (_currentQuestionIndex + 1) / _questions.length;

  void initializeQuestions(BuildContext context) {
    _questions = getQuestions(context);
  }

  Question get currentQuestion => _questions[_currentQuestionIndex];

  void answerCurrentQuestion(String answer) {
    _answers.add(answer);
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
    }
  }

  bool isComplete() => _currentQuestionIndex >= _questions.length;

  List<String> get answers => _answers;

  List<Question> get questions => _questions;
}
