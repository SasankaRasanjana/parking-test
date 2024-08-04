import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Payment {
  final String? id;
  final DateTime checkinTime;
  final DateTime checkoutTime;
  final DateTime date;
  final TimeOfDay fromTime;
  final String parkId;
  final String slotId;
  final String status;
  final TimeOfDay toTime;
  final String userId;

  Payment({
    this.id,
    required this.checkinTime,
    required this.checkoutTime,
    required this.date,
    required this.fromTime,
    required this.parkId,
    required this.slotId,
    required this.status,
    required this.toTime,
    required this.userId,
  });

  factory Payment.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Payment(
      id: doc.id,
      checkinTime: (data['checkinTime'] as Timestamp).toDate(),
      checkoutTime: (data['checkoutTime'] as Timestamp).toDate(),
      date: (data['date'] as Timestamp).toDate(),
      fromTime: TimeOfDay(
        hour: data['fromTime']['hour'],
        minute: data['fromTime']['minute'],
      ),
      parkId: data['parkId'],
      slotId: data['slotId'],
      status: data['status'],
      toTime: TimeOfDay(
        hour: data['toTime']['hour'],
        minute: data['toTime']['minute'],
      ),
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'checkinTime': Timestamp.fromDate(checkinTime),
      'checkoutTime': Timestamp.fromDate(checkoutTime),
      'date': Timestamp.fromDate(date),
      'fromTime': {
        'hour': fromTime.hour,
        'minute': fromTime.minute,
      },
      'parkId': parkId,
      'slotId': slotId,
      'status': status,
      'toTime': {
        'hour': toTime.hour,
        'minute': toTime.minute,
      },
      'userId': userId,
    };
  }
}
