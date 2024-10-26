// lib/widgets/question_card.dart

import 'package:flutter/material.dart';
import '../models/question.dart'; // Ensure you import the Question model

class QuestionCard extends StatelessWidget {
  final Question question;

  const QuestionCard({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              question.text, // Access the text property of the Question object
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
