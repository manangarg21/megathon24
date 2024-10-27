import 'package:flutter/material.dart';
import '../widgets/question_card.dart';
import '../services/journal_service.dart';
import '../models/question.dart'; // Import the Question model

class HomePage extends StatelessWidget {
  final JournalService _journalService = JournalService();

  @override
  Widget build(BuildContext context) {
    // Retrieve the daily question from JournalService
    final Question dailyQuestion = _journalService.getDailyQuestion(); // Get the Question object

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Journal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to your Daily Journal!',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // Pass the entire Question object to QuestionCard
            QuestionCard(question: dailyQuestion), 
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/new-entry');
              },
              child: Text('New Entry'),
            ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/view-entries');
            //   },
            //   child: Text('View Entries'),
            // ),
          ],
        ),
      ),
    );
  }
}
