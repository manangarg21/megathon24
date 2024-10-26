// lib/screens/new_entry_page.dart

import 'package:flutter/material.dart';
import '../data/questions.dart'; // Import the questions list
import '../models/journal_entry.dart';
import '../services/database_helper.dart'; // Import the DatabaseHelper

class NewEntryPage extends StatefulWidget {
  @override
  _NewEntryPageState createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final _entryController = TextEditingController();
  final _responseController = TextEditingController();
  String dailyQuestion = ''; // Placeholder for the daily question

  @override
  void initState() {
    super.initState();
    dailyQuestion = _getDailyQuestion(); // Set the daily question
  }

  String _getDailyQuestion() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays + 1;
    final index = dayOfYear % questions.length; // Cycle through questions
    return questions[index];
  }

  Future<void> _saveEntry() async {
    final newEntry = JournalEntry(
      date: DateTime.now(),
      question: dailyQuestion,
      response: _responseController.text,
    );
    print(newEntry);
    await DatabaseHelper.instance.addJournalEntry(newEntry);

    // Clear the input fields after saving
    _entryController.clear();
    _responseController.clear();

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Entry saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Entries'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Journal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _entryController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write about your day...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            Text(
              dailyQuestion,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _responseController,
              decoration: InputDecoration(
                hintText: 'Your answer to today\'s question...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEntry, // Call _saveEntry when button is pressed
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
