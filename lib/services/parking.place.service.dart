import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkme/models/parking.place.model.dart';

class ParkingPlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add or update a ParkingPlace
  Future<void> setParkingPlace(ParkingPlace parkingPlace) async {
    try {
      await _firestore
          .collection('parkingPlaces')
          .doc(_auth.currentUser?.uid)
          .set(parkingPlace.toMap(), SetOptions(merge: true));
    } catch (e) {
      _handleError(e);
    }
  }

  // Get a ParkingPlace by ID
  Future<ParkingPlace?> getParkingPlaceById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('parkingPlaces').doc(id).get();
      if (doc.exists) {
        return ParkingPlace.fromDocumentSnapshot(doc);
      } else {
        print('Parking place not found');
        return null;
      }
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // Get all ParkingPlaces for the current user
  Future<List<ParkingPlace>> getParkingPlacesByOwnerId() async {
    try {
      String? ownerId = _auth.currentUser?.uid;
      if (ownerId == null)
        throw FirebaseAuthException(
            code: 'no-user', message: 'No authenticated user found.');

      QuerySnapshot querySnapshot = await _firestore
          .collection('parkingPlaces')
          .where('ownerId', isEqualTo: ownerId)
          .get();
      return querySnapshot.docs
          .map((doc) => ParkingPlace.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // Delete a ParkingPlace by ID
  Future<void> deleteParkingPlaceById(String id) async {
    try {
      await _firestore.collection('parkingPlaces').doc(id).delete();
    } catch (e) {
      _handleError(e);
    }
  }

  // Handle errors
  void _handleError(dynamic e) {
    if (e is FirebaseAuthException) {
      print('Firebase Auth Error: ${e.message}');
    } else if (e is FirebaseException) {
      print('Firebase Error: ${e.message}');
    } else {
      print('General Error: $e');
    }
  }
}
