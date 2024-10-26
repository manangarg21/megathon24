import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import '../models/journal_entry.dart';

class ViewEntriesPage extends StatelessWidget {
  final DateTime selectedDate;

  ViewEntriesPage({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Entries for ${DateFormat('MMM d, yyyy').format(selectedDate)}'),
      ),
      body: FutureBuilder<List<JournalEntry>>(
        future: fetchEntriesForDate(selectedDate),  // Fetch entries by selectedDate
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading entries'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No entries for this date'));
          }

          final entries = snapshot.data!;

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                title: Text(entry.question),
                subtitle: Text(entry.response),
                onTap: () {
                  // Navigate to detail or edit page if needed
                },
              );
            },
          );
        },
      ),
    );
  }

  // Use DatabaseHelper to fetch entries by selected date
  Future<List<JournalEntry>> fetchEntriesForDate(DateTime date) async {
    final db = DatabaseHelper.instance;
    return await db.fetchJournalEntriesByDate(date);  // Fetch directly using MongoDB query
  }
}
