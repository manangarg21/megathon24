// // lib/services/database_helper.dart
// lib/services/database_helper.dart
// lib/services/database_helper.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';
import '../models/journal_entry.dart';
import '../models/question.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static const String API_BASE_URL =
      'http://localhost:3000/api'; // Change this for production

  DatabaseHelper._init();

  get database => null;

  Future<ObjectId> addJournalEntry(JournalEntry entry) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/journal-entries'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(entry.toMap()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return ObjectId.parse(data['id']);
      } else {
        throw Exception('Failed to add journal entry');
      }
    } catch (e) {
      print('Error adding journal entry: $e');
      rethrow;
    }
  }

  Future<List<JournalEntry>> fetchJournalEntries() async {
    try {
      final response =
          await http.get(Uri.parse('$API_BASE_URL/journal-entries'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => JournalEntry.fromMap(json)).toList();
      } else {
        throw Exception('Failed to fetch journal entries');
      }
    } catch (e) {
      print('Error fetching journal entries: $e');
      rethrow;
    }
  }

  Future<List<JournalEntry>> fetchJournalEntriesByDate(DateTime date) async {
    try {
      final response = await http.get(Uri.parse(
          '$API_BASE_URL/journal-entries/date/${date.toIso8601String()}'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => JournalEntry.fromMap(json)).toList();
      } else {
        throw Exception('Failed to fetch journal entries by date');
      }
    } catch (e) {
      print('Error fetching journal entries by date: $e');
      rethrow;
    }
  }

  Future<void> updateJournalEntry(JournalEntry entry) async {
    try {
      if (entry.id == null) throw Exception('Entry ID is required for update');

      final response = await http.put(
        Uri.parse('$API_BASE_URL/journal-entries/${entry.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(entry.toMap()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update journal entry');
      }
    } catch (e) {
      print('Error updating journal entry: $e');
      rethrow;
    }
  }

  Future<void> deleteJournalEntry(ObjectId id) async {
    try {
      final response = await http.delete(
        Uri.parse('$API_BASE_URL/journal-entries/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete journal entry');
      }
    } catch (e) {
      print('Error deleting journal entry: $e');
      rethrow;
    }
  }

  Future<List<Question>> fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/questions'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Question.fromMap(json)).toList();
      } else {
        throw Exception('Failed to fetch questions');
      }
    } catch (e) {
      print('Error fetching questions: $e');
      rethrow;
    }
  }
}
// import 'package:mongo_dart/mongo_dart.dart';
// import '../models/journal_entry.dart';
// import '../models/question.dart';

// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   static Db? _database;
  
//   // Replace with your MongoDB connection string from MongoDB Atlas
//   static const String MONGO_CONN_URL = 'mongodb+srv://kushagradhingra:BAK7fISZJBBg5wkY@cluster.yrtp0.mongodb.net/?retryWrites=true&w=majority&appName=Cluster';
//   static const String USER_COLLECTION = '';
//   static const String QUESTIONS_COLLECTION = 'questions';

//   DatabaseHelper._init();

//   Future<Db> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB();
//     return _database!;
//   }

//   Future<Db> _initDB() async {
//     final db = await Db.create(MONGO_CONN_URL);
//     await db.open();
//     return db;
//   }

//   // Add JournalEntry to the database
//   Future<ObjectId> addJournalEntry(JournalEntry entry) async {
//     final db = await database;
//     final collection = db.collection(USER_COLLECTION);
    
//     final result = await collection.insertOne(entry.toMap());
//     return result.id;
//   }

//   // Add Question to the database
//   Future<ObjectId> addQuestion(Question question) async {
//     final db = await database;
//     final collection = db.collection(QUESTIONS_COLLECTION);
    
//     final result = await collection.insertOne(question.toMap());
//     return result.id;
//   }

//   // Fetch all JournalEntries from the database
//   Future<List<JournalEntry>> fetchJournalEntries() async {
//     final db = await database;
//     final collection = db.collection(USER_COLLECTION);
    
//     final results = await collection.find().toList();
//     return results.map((json) => JournalEntry.fromMap(json)).toList();
//   }

//   // Fetch all Questions from the database
//   Future<List<Question>> fetchQuestions() async {
//     final db = await database;
//     final collection = db.collection(QUESTIONS_COLLECTION);
    
//     final results = await collection.find().toList();
//     return results.map((json) => Question.fromMap(json)).toList();
//   }

//   // Close the database connection
//   Future close() async {
//     final db = await database;
//     await db.close();
//   }
// }

// KX3l8FO3DZVaQzSy