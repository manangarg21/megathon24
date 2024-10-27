// lib/models/user.dart
import 'package:mongo_dart/mongo_dart.dart';

class User {
  final ObjectId? id;
  final String email;
  final String password; // Added password field

  User({
    this.id,
    required this.email,
    required this.password, // Make password a required field
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id.toString(),
      'email': email,
      // Do not expose the password in the map
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] != null 
          ? (map['_id'] is String ? ObjectId.parse(map['_id']) : map['_id']) 
          : null,
      email: map['email'],
      password: map['password'] ?? '', // Default to empty if password is not present
    );
  }
}
