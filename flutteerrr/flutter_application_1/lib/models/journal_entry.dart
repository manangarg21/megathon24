// // // lib/models/journal_entry.dart
import 'package:mongo_dart/mongo_dart.dart';

class JournalEntry {
  final ObjectId? id;
  final DateTime date;
  final String question;
  final String response;

  JournalEntry({
    this.id,
    required this.date,
    required this.question,
    required this.response,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id.toString(),
      'date': date.toIso8601String(),
      'question': question,
      'response': response,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['_id'] != null ? 
          (map['_id'] is String ? 
              ObjectId.parse(map['_id']) : 
              map['_id']) : null,
      date: DateTime.parse(map['date']),
      question: map['question'],
      response: map['response'],
    );
  }
}
// class JournalEntry {
//   final int? id;
//   final DateTime date;
//   final String question;
//   final String response;

//   JournalEntry({
//     this.id, 
//     required this.date, 
//     required this.question, 
//     required this.response
//   });

//   // Convert JournalEntry object to map (for database storage)
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'date': date.toIso8601String(), // Fix: Added () to call the method
//       'question': question,
//       'response': response,
//     };
//   }

//   // Add fromMap factory constructor
//   factory JournalEntry.fromMap(Map<String, dynamic> map) {
//     return JournalEntry(
//       id: map['id'],
//       date: DateTime.parse(map['date']),
//       question: map['question'],
//       response: map['response'],
//     );
//   }
// }