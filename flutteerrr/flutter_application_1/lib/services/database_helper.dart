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
        Uri.parse('$API_BASE_URL/journal-entries/${entry.userId}'), // Pass userId in the URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode(entry.toMap()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ObjectId.parse(data['id']);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
  Future<List<JournalEntry>> fetchJournalEntries(String userId) async {
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/journal-entries/$userId')); // Pass userId in the URL

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

  Future<List<JournalEntry>> fetchJournalEntriesByDate(DateTime date, String? userId) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/journal-entries/date/$userId'), // Pass userId in the URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'dateVal': date.toIso8601String()}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => JournalEntry.fromMap(json)).toList();
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> updateJournalEntry(JournalEntry entry, String? userId) async {
    try {
      if (entry.id == null) throw Exception('Entry ID is required for update');

      final response = await http.put(
        Uri.parse('$API_BASE_URL/journal-entries/${entry.id}?userId=$userId'),
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

  Future<void> deleteJournalEntry(ObjectId id, String? userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$API_BASE_URL/journal-entries/$id/$userId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete journal entry');
      }
    } catch (e) {
      print('Error deleting journal entry: $e');
      rethrow;
    }
  }

  Future<List<Question>> fetchQuestions(String? userId) async {
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/questions/$userId'));

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
