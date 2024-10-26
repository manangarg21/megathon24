// lib/widgets/question_card.dart

import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String question;

  QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          question,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
