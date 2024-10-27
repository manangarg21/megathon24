import '../services/database_helper.dart'; // Import your MongoDB helper
import '../models/journal_entry.dart';
import '../models/question.dart'; // Import the Question model
import '../data/questions.dart'; // Import the questions list

class JournalService {
  static final JournalService _instance = JournalService._internal();
  
  JournalService._internal();

  factory JournalService() {
    return _instance;
  }

  // Add a new journal entry using DatabaseHelper
  Future<void> addJournalEntry(JournalEntry entry) async {
    await DatabaseHelper.instance.addJournalEntry(entry);
  }

  // Retrieve entries for a specific date using DatabaseHelper
  Future<List<JournalEntry>> getEntriesForDate(String date) async {
    return await DatabaseHelper.instance.fetchJournalEntriesByDate(DateTime.parse(date));
  }

  // Generate or retrieve the daily question
  Question getDailyQuestion() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays + 1;
    final index = dayOfYear % questions.length; // Cycle through questions
    return Question(text: questions[index]); // Return a Question object
  }
}

