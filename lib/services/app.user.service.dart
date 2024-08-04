import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkme/models/app.user.model.dart';

class AppUserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update an AppUser
  Future<void> setUser(AppUser user) async {
    String? uid = _auth.currentUser?.uid;

    if (uid != null) {
      await _firestore
          .collection('parkmeusers')
          .doc(uid)
          .set(user.toMap(), SetOptions(merge: true));
    } else {
      throw FirebaseAuthException(
          code: 'no-user', message: 'No authenticated user found.');
    }
  }

  // Get an AppUser by UID
  Future<AppUser?> getUser() async {
    String? uid = _auth.currentUser?.uid;

    if (uid != null) {
      DocumentSnapshot doc =
          await _firestore.collection('parkmeusers').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromDocumentSnapshot(doc);
      } else {
        return null;
      }
    } else {
      throw FirebaseAuthException(
          code: 'no-user', message: 'No authenticated user found.');
    }
  }

  // Delete an AppUser by UID
  Future<void> deleteUser() async {
    String? uid = _auth.currentUser?.uid;

    if (uid != null) {
      await _firestore.collection('parkmeusers').doc(uid).delete();
    } else {
      throw FirebaseAuthException(
          code: 'no-user', message: 'No authenticated user found.');
    }
  }
}
