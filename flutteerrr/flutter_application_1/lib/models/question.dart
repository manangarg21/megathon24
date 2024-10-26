// // lib/models/question.dart
import 'package:mongo_dart/mongo_dart.dart';

class Question {
  final ObjectId? id;
  final String text;

  Question({
    this.id,
    required this.text,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id.toString(),
      'text': text,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['_id'] != null ? 
          (map['_id'] is String ? 
              ObjectId.parse(map['_id']) : 
              map['_id']) : null,
      text: map['text'],
    );
  }
}
// lib/models/question.dart

// class Question {
//   final int? id; // Optional to allow auto-increment
//   final String text;

//   Question({this.id, required this.text});

//   // Convert to map for SQL storage
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'text': text,
//     };
//   }

//   // Load from map for SQL retrieval
//   factory Question.fromMap(Map<String, dynamic> map) {
//     return Question(
//       id: map['id'],
//       text: map['text'],
//     );
//   }
// }
