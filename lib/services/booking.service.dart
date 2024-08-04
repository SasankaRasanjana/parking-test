import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkme/models/booking.model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'bookings';

  Future<void> createBooking(Booking booking) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(booking.parkId)
          .set({"parkId": booking.parkId});
      await _firestore
          .collection(collectionPath)
          .doc(booking.parkId)
          .collection("slots")
          .add(booking.toMap());
    } catch (e) {
      print('Error creating booking: $e');
      // Handle the error appropriately in your application
    }
  }

  Future<Booking?> getBookingById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collectionPath).doc(id).get();
      if (doc.exists) {
        return Booking.fromDocumentSnapshot(doc);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching booking: $e');

      return null;
    }
  }

  Future<void> updateBookingStatus(String bookingId, String parkId) async {
    try {
      print(bookingId);
      await _firestore
          .collection(collectionPath)
          .doc(parkId)
          .collection("slots")
          .doc(bookingId)
          .update({
        "status": "completed",
      });
      try {
        await _firestore
            .collection("ongoingBookings")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          "status": "completed",
        });
      } catch (e) {
        print(e);
      }
    } catch (e) {
      throw Error.safeToString(e.toString());
    }
  }

  Future<void> updateBooking(Booking booking,
      {String status = "ongoing"}) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(booking.parkId)
          .collection("slots")
          .doc(booking.id)
          .update(booking.toMap());

      await _firestore
          .collection("ongoingBookings")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
        ...booking.toMap(),
        "status": status,
        "bookingId": booking.id,
        "checkinTime": DateTime.now(),
      });
    } catch (e) {
      print('Error updating booking: $e');
      // Handle the error appropriately in your application
    }
  }

  Future<void> deleteBooking(String id) async {
    try {
      await _firestore.collection(collectionPath).doc(id).delete();
    } catch (e) {
      print('Error deleting booking: $e');
      // Handle the error appropriately in your application
    }
  }

  Future<List<Booking>> getBookingsByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionPath)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => Booking.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching user bookings: $e');
      // Handle the error appropriately in your application
      return [];
    }
  }

  Future<List<Booking>> getBookingsByParkId(String parkId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionPath)
          .where('parkId', isEqualTo: parkId)
          .get();

      return querySnapshot.docs
          .map((doc) => Booking.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching park bookings: $e');
      // Handle the error appropriately in your application
      return [];
    }
  }
}
