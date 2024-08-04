import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkme/models/feedback.model.dart';

class FeedbackService {
  final CollectionReference _feedbackCollection =
      FirebaseFirestore.instance.collection('feedback');

  Future<void> addFeedback(FeedbackModel feedback) async {
    try {
      await _feedbackCollection.add(feedback.toMap());
    } catch (e) {
      throw Exception('Failed to add feedback: $e');
    }
  }

  Future<void> updateFeedback(FeedbackModel feedback) async {
    try {
      await _feedbackCollection.doc(feedback.id).update(feedback.toMap());
    } catch (e) {
      throw Exception('Failed to update feedback: $e');
    }
  }

  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _feedbackCollection.doc(feedbackId).delete();
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }

  Stream<List<FeedbackModel>> getFeedbackStream() {
    try {
      return _feedbackCollection.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => FeedbackModel.fromDocumentSnapshot(doc))
          .toList());
    } catch (e) {
      throw Exception('Failed to get feedback stream: $e');
    }
  }
}
