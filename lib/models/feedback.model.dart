import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String? id;
  final bool isPositive;
  final String comment;
  final String reviewedBy;
  final String reviewedAt; // Use Timestamp for Firestore timestamp fields

  FeedbackModel({
    this.id,
    this.isPositive = true,
    this.comment = '',
    required this.reviewedBy,
    required this.reviewedAt,
  });

  factory FeedbackModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Failed to load data from document');
    }
    return FeedbackModel(
      id: snapshot.id,
      isPositive: data['isPositive'] ?? true,
      comment: data['comment'] ?? '',
      reviewedBy: data['reviewedBy'] ?? '',
      reviewedAt: data['reviewedAt'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isPositive': isPositive,
      'comment': comment,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt,
    };
  }
}
