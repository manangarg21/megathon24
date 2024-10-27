import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/questions.dart';
import '../models/journal_entry.dart';
import '../services/database_helper.dart'; // Import the DatabaseHelper
import '../services/journal_service.dart'; // Import the JournalService

class NewEntryPage extends StatefulWidget {
  @override
  _NewEntryPageState createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  var _entryController = TextEditingController();
  var _responseController = TextEditingController();
  // final _journalController= TextEditingController();
  String dailyQuestion = ''; // Placeholder for the daily question

  @override
  void initState() {
    super.initState();
    dailyQuestion = _getDailyQuestion(); // Set the daily question
  }

  String _getDailyQuestion() {
    final question =
        JournalService().getDailyQuestion(); // Fetch the daily question
    return question.text; // Return the text of the Question object
  }

  Future<void> _saveEntry() async {
    if (_responseController == null) {
        _responseController = TextEditingController(text: " ");
    }
    if (_entryController == null) {
      _entryController = TextEditingController(text: " ");
    }
      final newEntry = JournalEntry(
      date: DateTime.now(),
      question: dailyQuestion,
      response: _responseController.text,
      journal: _entryController.text,
    );
    print(newEntry.journal);
    await DatabaseHelper.instance.addJournalEntry(newEntry);
    // Clear the input fields after saving
    _entryController.clear();
    _responseController.clear();

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Entries'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Journal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _entryController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write about your day...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dailyQuestion,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _responseController,
              decoration: const InputDecoration(
                hintText: 'Your answer to today\'s question...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEntry, // Call _saveEntry when button is pressed
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}