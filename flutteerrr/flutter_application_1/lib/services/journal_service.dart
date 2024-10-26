import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';

class JournalService {
  static final JournalService _instance = JournalService._internal();
  static Database? _database;

  JournalService._internal();

  factory JournalService() {
    return _instance;
  }

  // Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'journal.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE entries(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, question TEXT, response TEXT)',
        );
      },
    );
  }

  // Function to add a new journal entry
  Future<void> addJournalEntry(JournalEntry entry) async {
    final db = await database;
    await db.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve entries for a specific date
  Future<List<JournalEntry>> getEntriesForDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entries',
      where: 'date = ?',
      whereArgs: [date],
    );

    return List.generate(maps.length, (i) {
      return JournalEntry(
        id: maps[i]['id'],
        date: maps[i]['date'],
        question: maps[i]['question'],
        response: maps[i]['response'],
      );
    });
  }

// Generate or retrieve daily question
  String getDailyQuestion() {
    // Placeholder implementation; replace with actual question generation logic
    return 'What made you happy today?';
  }

  
}
