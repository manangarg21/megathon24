// // lib/models/question.dart

// class Question {
//   final String text;

//   Question({required this.text});

//   Map<String, dynamic> toJson() => {
//         'text': text,
//       };

//   factory Question.fromJson(Map<String, dynamic> json) => Question(
//         text: json['text'],
//       );
// }
// lib/models/question.dart

class Question {
  final int? id; // Optional to allow auto-increment
  final String text;

  Question({this.id, required this.text});

  // Convert to map for SQL storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
    };
  }

  // Load from map for SQL retrieval
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      text: map['text'],
    );
  }
}
