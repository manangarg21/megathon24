// // import 'package:sqflite/sqflite.dart';
// // import 'package:path/path.dart';
// // import '../models/journal_entry.dart';

// // class JournalService {
// //   static final JournalService _instance = JournalService._internal();
// //   static Database? _database;

// //   JournalService._internal();

// //   factory JournalService() {
// //     return _instance;
// //   }

// //   // Initialize database
// //   Future<Database> get database async {
// //     if (_database != null) return _database!;
// //     _database = await _initDatabase();
// //     return _database!;
// //   }

// //   Future<Database> _initDatabase() async {
// //     String path = join(await getDatabasesPath(), 'journal.db');
// //     return await openDatabase(
// //       path,
// //       version: 1,
// //       onCreate: (db, version) {
// //         return db.execute(
// //           'CREATE TABLE entries(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, question TEXT, response TEXT)',
// //         );
// //       },
// //     );
// //   }

// //   // Function to add a new journal entry
// //   Future<void> addJournalEntry(JournalEntry entry) async {
// //     final db = await database;
// //     await db.insert(
// //       'entries',
// //       entry.toMap(),
// //       conflictAlgorithm: ConflictAlgorithm.replace,
// //     );
// //   }

// //   // Retrieve entries for a specific date
// //   Future<List<JournalEntry>> getEntriesForDate(String date) async {
// //     final db = await database;
// //     final List<Map<String, dynamic>> maps = await db.query(
// //       'entries',
// //       where: 'date = ?',
// //       whereArgs: [date],
// //     );

// //     return List.generate(maps.length, (i) {
// //       return JournalEntry(
// //         id: maps[i]['id'],
// //         date: maps[i]['date'],
// //         question: maps[i]['question'],
// //         response: maps[i]['response'],
// //       );
// //     });
// //   }

// // // Generate or retrieve daily question
// //   String getDailyQuestion() {
// //     // Placeholder implementation; replace with actual question generation logic
// //     return 'What made you happy today?';
// //   }

  
// // }
// import '../services/database_helper.dart'; // Import your MongoDB helper
// import '../models/journal_entry.dart';

// class JournalService {
//   static final JournalService _instance = JournalService._internal();
  
//   JournalService._internal();

//   factory JournalService() {
//     return _instance;
//   }

//   // Add a new journal entry using DatabaseHelper
//   Future<void> addJournalEntry(JournalEntry entry) async {
//     await DatabaseHelper.instance.addJournalEntry(entry);
//   }

//   // Retrieve entries for a specific date using DatabaseHelper
//   Future<List<JournalEntry>> getEntriesForDate(String date) async {
//     return await DatabaseHelper.instance.fetchJournalEntriesByDate(DateTime.parse(date));
//   }

//   // Generate or retrieve the daily question
//   String getDailyQuestion() {
//     // Placeholder implementation; replace with actual question generation logic
//     return 'What made you happy today?';
//   }
// }
// lib/services/journal_service.dart

// lib/services/journal_service.dart

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

