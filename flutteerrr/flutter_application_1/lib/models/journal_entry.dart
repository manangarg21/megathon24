// // // lib/models/journal_entry.dart

// // class JournalEntry {
// //   final DateTime date;
// //   final List<String> responses;

// //   JournalEntry({
// //     required this.date,
// //     required this.responses,
// //   });

// //   // Method to add a new response
// //   void addResponse(String response) {
// //     responses.add(response);
// //   }

// //   // Convert to JSON for storage, with a list for responses
// //   Map<String, dynamic> toJson() => {
// //         'date': date.toIso8601String(),
// //         'responses': responses,
// //       };

// //   // Load from JSON, mapping responses to a List<String>
// //   factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
// //         date: DateTime.parse(json['date']),
// //         responses: List<String>.from(json['responses']),
// //       );
// // }
// class JournalEntry {
//   final int? id;
//   final DateTime date;
//   final String question;
//   final String response;

//   JournalEntry({this.id, required this.date, required this.question, required this.response});

//   // Convert JournalEntry object to map (for database storage)
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'date': date.toIso8601String,
//       'question': question,
//       'response': response,
//     };
//   }
// }
class JournalEntry {
  final int? id;
  final DateTime date;
  final String question;
  final String response;

  JournalEntry({
    this.id, 
    required this.date, 
    required this.question, 
    required this.response
  });

  // Convert JournalEntry object to map (for database storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(), // Fix: Added () to call the method
      'question': question,
      'response': response,
    };
  }

  // Add fromMap factory constructor
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      question: map['question'],
      response: map['response'],
    );
  }
}