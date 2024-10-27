// lib/models/journal_entry.dart
import 'package:mongo_dart/mongo_dart.dart';

class JournalEntry {
  final ObjectId? id;
  final DateTime date;
  final String question;
  final String response;
  final String journal;
  final String userId; // Add this field to relate the entry to a user

  JournalEntry({
    this.id,
    required this.date,
    required this.question,
    required this.response,
    required this.journal,
    required this.userId, // Update the constructor
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id.toString(),
      'date': date.toIso8601String(),
      'question': question,
      'response': response,
      'journal': journal,
      'userId': userId, // Include userId in the map
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['_id'] != null
          ? (map['_id'] is String ? ObjectId.parse(map['_id']) : map['_id'])
          : null,
      date: DateTime.parse(map['date']),
      question: map['question'],
      response: map['response'],
      journal: map['journal'],
      userId: map['userId'], // Retrieve userId from the map
    );
  }
}
