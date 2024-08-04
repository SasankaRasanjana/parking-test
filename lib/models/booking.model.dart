import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Booking {
  final String? id;
  final String parkId;
  final String userId;
  final String slotId;
  final DateTime date;
  final TimeOfDay fromTime;
  final TimeOfDay toTime;
  String status;
  Booking({
    this.id,
    required this.parkId,
    required this.userId,
    required this.slotId,
    required this.date,
    required this.fromTime,
    required this.toTime,
    this.status = "pending",
  });
  set setStatus(String value) => status = value;
  factory Booking.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Booking(
        id: doc.id,
        parkId: data['parkId'] ?? '',
        userId: data['userId'] ?? '',
        slotId: data['slotId'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        fromTime: TimeOfDay(
          hour: data['fromTime']['hour'] ?? 0,
          minute: data['fromTime']['minute'] ?? 0,
        ),
        toTime: TimeOfDay(
          hour: data['toTime']['hour'] ?? 0,
          minute: data['toTime']['minute'] ?? 0,
        ),
        status: data['status'] ?? "pending");
  }

  Map<String, dynamic> toMap() {
    return {
      'parkId': parkId,
      'userId': userId,
      'slotId': slotId,
      'date': Timestamp.fromDate(date),
      'fromTime': {'hour': fromTime.hour, 'minute': fromTime.minute},
      'toTime': {'hour': toTime.hour, 'minute': toTime.minute},
      'status': status,
    };
  }
}
