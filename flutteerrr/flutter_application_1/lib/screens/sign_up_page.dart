import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupPage extends StatelessWidget {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signup(BuildContext context) async {
    try {
      String userId = await _authService.signup(
        _emailController.text,
        _passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/', arguments: userId);
    } catch (e) {
      print('Error signing up: $e');
      // You might want to show an error message here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => _signup(context),
              child: Text('Signup'),
            ),
            SizedBox(height: 20), // Space between buttons
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login'); // Change to your login route
              },
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
