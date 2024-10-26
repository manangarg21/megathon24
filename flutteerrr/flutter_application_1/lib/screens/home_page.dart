// // lib/screens/home_page.dart

// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Daily Journal'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Welcome to your Daily Journal!',
//               style: TextStyle(fontSize: 24),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/new-entry');
//               },
//               child: Text('New Entry'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/view-entries');
//               },
//               child: Text('View Entries'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import '../widgets/question_card.dart';
import '../services/journal_service.dart';

class HomePage extends StatelessWidget {
  final JournalService _journalService = JournalService();

  @override
  Widget build(BuildContext context) {
    // Retrieve daily question from the JournalService
    final String dailyQuestion = "Today's Question : " + _journalService.getDailyQuestion();

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Journal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to your Daily Journal!',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // Displaying the daily question using QuestionCard
            QuestionCard(question: dailyQuestion),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/new-entry');
              },
              child: Text('New Entry'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/view-entries');
              },
              child: Text('View Entries'),
            ),
          ],
        ),
      ),
    );
  }
}
