import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String API_BASE_URL = 'http://localhost:3000/api';

  // Signup function
  Future<String> signup(String email, String password) async {
    final response = await http.post(
      Uri.parse('$API_BASE_URL/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String userId = data['userId'];

      // Store userId in SharedPreferences
      await _storeUserId(userId);

      return userId;
    } else {
      throw Exception(response.body);
    }
  }

  // Login function
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$API_BASE_URL/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String userId = data['userId'];

      // Store userId in SharedPreferences
      await _storeUserId(userId);

      return userId;
    } else {
      throw Exception('Failed to log in');
    }
  }

  // Helper method to store userId in SharedPreferences
  Future<void> _storeUserId(String userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('id', userId);
  }
}
