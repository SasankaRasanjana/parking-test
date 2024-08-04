import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkme/models/panalty.model.dart';

class PenaltyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Penalty>> getPenaltiesByParkId(String parkId) {
    return _db
        .collection('penalties')
        .where('parkId', isEqualTo: parkId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Penalty.fromMap(doc.data(), doc.id))
            .toList());
  }
}
