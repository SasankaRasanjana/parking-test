import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String email;
  final String username;
  final String role;

  AppUser({
    required this.email,
    required this.username,
    required this.role,
  });

  // Create an AppUser instance from a Firestore document snapshot
  factory AppUser.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return AppUser(
      email: data['email'] ?? 'no-email@example.com',
      username: data['username'] ?? 'anonymous',
      role: data['role'] ?? 'user',
    );
  }

  // Convert an AppUser instance to a map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'role': role,
    };
  }
}
