import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/progress_provider.dart';
import '../models/progress_model.dart'; // Update to the correct model import
import 'package:lexilearn/themes/themes.dart';

class QuizScreen extends StatefulWidget {
 const QuizScreen({Key? key}) : super(key: key);

 @override
 State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
 final List<Map<String, dynamic>> _questions = [
   {
     'question': "What is the capital of France?",
     'options': ['London', 'Paris', 'Rome', 'Berlin'],
     'answerIndex': 1,
   },
   {
     'question': "What is 2 + 2?",
     'options': ['3', '4', '5', '6'],
     'answerIndex': 1,
   },
   {
     'question': "Which language is Flutter written in?",
     'options': ['Java', 'Kotlin', 'Dart', 'Swift'],
     'answerIndex': 2,
   },
 ];

 int _currentIndex = 0;
 int _correctAnswers = 0;
 late List<int?> _selectedAnswers;
 bool _quizFinished = false;

 @override
 void initState() {
   super.initState();
   _selectedAnswers = List<int?>.filled(_questions.length, null);
 }

 void _selectAnswer(int index) {
   if (_selectedAnswers[_currentIndex] != null || _quizFinished) return; // no changes after finish
   setState(() {
     _selectedAnswers[_currentIndex] = index;
     if (index == _questions[_currentIndex]['answerIndex']) _correctAnswers++;
   });
 }

 Future<void> _next() async {
   if (_selectedAnswers[_currentIndex] == null || _quizFinished) return;

   if (_currentIndex < _questions.length - 1) {
     setState(() {
       _currentIndex++;
     });
   } else {
     setState(() {
       _quizFinished = true;
     });

     final accuracy = (_correctAnswers / _questions.length) * 100;
     final provider = Provider.of<ProgressProvider>(context, listen: false);

     // Create a progress entry representing this quiz's result
     final progressEntry = ProgressEntry(
       contentId: 'quiz_${DateTime.now().millisecondsSinceEpoch}', // Unique ID for the quiz session
       progress: 1.0,
       accuracy: accuracy,
       score: _correctAnswers.toDouble(),
       date: DateTime.now(),
       
     );

     // Add progress entry via provider
     provider.addProgress(progressEntry);

     // Show snackbar message
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Quiz is finished. Check progress screen for results.')),
     );
   }
 }

 @override
 Widget build(BuildContext context) {
   final question = _questions[_currentIndex];
   final answered = _selectedAnswers[_currentIndex] != null;

   return Scaffold(
     appBar: AppBar(
       title: Text('Question ${_currentIndex + 1}/${_questions.length}'),
     ),
     body: Padding(
       padding: const EdgeInsets.all(16),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(question['question'],
               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
           const SizedBox(height: 20),
           ...List.generate(
             question['options'].length,
             (index) => RadioListTile<int>(
               title: Text(question['options'][index]),
               value: index,
               groupValue: _selectedAnswers[_currentIndex],
               onChanged: answered || _quizFinished ? null : (int? val) => _selectAnswer(val!),
             ),
           ),
           const Spacer(),
           ElevatedButton(
             onPressed: answered && !_quizFinished ? _next : null,
             child: Text(_quizFinished ? 'Finished' : (_currentIndex == _questions.length - 1 ? 'Finish' : 'Next')),
           ),
         ],
       ),
     ),
   );
 }
}
