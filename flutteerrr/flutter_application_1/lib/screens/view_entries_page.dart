// lib/screens/view_entries_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart'; // Database service instead of JournalService
import '../models/journal_entry.dart';

class ViewEntriesPage extends StatelessWidget {
  final DateTime selectedDate;

  ViewEntriesPage({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    // Format date as "yyyy-MM-dd" for consistent SQL querying
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Entries for ${DateFormat('MMM d, yyyy').format(selectedDate)}'),
      ),
      body: FutureBuilder<List<JournalEntry>>(
        future: fetchEntriesForDate(formattedDate),
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
                  // You can navigate to an edit or detail page here if needed
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<JournalEntry>> fetchEntriesForDate(String formattedDate) async {
    final db = DatabaseHelper.instance;
    final entries = await db.fetchJournalEntries();
    return entries
        .where((entry) => DateFormat('yyyy-MM-dd').format(entry.date) == formattedDate)
        .toList();
  }
}
