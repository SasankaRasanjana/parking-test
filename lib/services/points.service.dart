import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointsService {
  final firbase = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  String? get uid => auth.currentUser?.uid;

  //add or update points
  Future<void> addOrUpdatePoints(int points) async {
    try {
      final snapshot = await firbase.collection("points").doc(uid).get();
      if (snapshot.exists) {
        int? lastPoints = (snapshot.data() as Map)["points"];
        await firbase
            .collection("points")
            .doc(uid)
            .update({"points": (lastPoints ?? 0) + points});
      } else {
        await firbase.collection("points").doc(uid).set({"points": points});
      }
    } catch (e) {
      throw Error.safeToString(e.toString());
    }
  }

  Future<void> reduceUsedPoints(int points) async {
    try {
      final snapshot = await firbase.collection("points").doc(uid).get();
      if (snapshot.exists) {
        int? lastPoints = (snapshot.data() as Map)["points"];
        await firbase
            .collection("points")
            .doc(uid)
            .update({"points": (lastPoints ?? 0) - points});
      }
    } catch (e) {
      throw Error.safeToString(e.toString());
    }
  }

  Future<int> getUsersPoints() async {
    try {
      final snapshot = await firbase.collection("points").doc(uid).get();
      if (snapshot.exists) {
        return (snapshot.data() as Map)["points"];
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
