// lib/screens/view_entries_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';
import '../models/journal_entry.dart';

class ViewEntriesPage extends StatefulWidget {
  @override
  _ViewEntriesPageState createState() => _ViewEntriesPageState();
}

class _ViewEntriesPageState extends State<ViewEntriesPage> {
  DateTime? selectedDate;
  Future<List<JournalEntry>>? _entriesFuture;
  String? userId;

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _entriesFuture = _fetchEntriesByDate(selectedDate!);
      });
    }
  }

  Future<List<JournalEntry>> _fetchEntriesByDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      // Fetch entries from backend for the selected date
      return await DatabaseHelper.instance.fetchJournalEntriesByDate(date,userId);
    } catch (e) {
      print('Error retrieving entries for $formattedDate: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserPreferences(); // Load user preferences on initialization
  }

  Future<void> _loadUserPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userId = preferences.getString('id'); 
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Entries'),
      ),
      body: Center(
        child: selectedDate == null
            ? ElevatedButton(
                onPressed: () => _pickDate(context),
                child: Text('Select Date to View Entries'),
              )
            : FutureBuilder<List<JournalEntry>>(
                future: _entriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error loading entries: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No entries for this date');
                  }

                  final entries = snapshot.data!;

                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(entry.question),
                          subtitle: Text(entry.response),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
