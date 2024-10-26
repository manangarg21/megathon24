// lib/services/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';
import '../models/question.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('journal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create JournalEntries table
    await db.execute('''
      CREATE TABLE JournalEntries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        question TEXT NOT NULL,
        response TEXT NOT NULL
      )
    ''');

    // Create Questions table
    await db.execute('''
      CREATE TABLE Questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL
      )
    ''');
  }

  // Add JournalEntry to the database
  Future<int> addJournalEntry(JournalEntry entry) async {
    final db = await database;
    print(entry);
    return await db.insert(
      'JournalEntries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Add Question to the database
  Future<int> addQuestion(Question question) async {
    final db = await database;
    return await db.insert(
      'Questions',
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all JournalEntries from the database
  Future<List<JournalEntry>> fetchJournalEntries() async {
    final db = await database;
    final result = await db.query('JournalEntries');
    return result.map((json) => JournalEntry.fromMap(json)).toList();
  }

  // Fetch all Questions from the database
  Future<List<Question>> fetchQuestions() async {
    final db = await database;
    final result = await db.query('Questions');
    return result.map((json) => Question.fromMap(json)).toList();
  }

  // Close the database connection
  Future close() async {
    final db = await database;
    db.close();
  }
}
