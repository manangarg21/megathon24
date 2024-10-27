import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_page.dart';
import 'screens/new_entry_page.dart';
import 'screens/view_entries_page.dart';
import 'screens/login_page.dart';
import 'screens/sign_up_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  try {
    await DatabaseHelper.instance.database;
    print('Database initialized successfully');
  } catch (e) {
    print('Error initializing database: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Journal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/': (context) => FutureBuilder<String?>(
              future: _getUserId(), // Load userId
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While loading, show a loader or a splash screen
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data != null) {
                  return HomePage(); // Navigate to HomePage if userId exists
                } else {
                  return SignupPage(); // Navigate to SignupPage if userId is not found
                }
              },
            ),
        '/new-entry': (context) => NewEntryPage(),
        '/view-entries': (context) => ViewEntriesPage(),
      },
    );
  }

  Future<String?> _getUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('id'); // Retrieve the userId from SharedPreferences
  }
}
