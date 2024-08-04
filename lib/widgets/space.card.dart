import 'package:card_loading/card_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkme/constants.dart';
import 'package:parkme/models/booking.model.dart';

class SpaceCard extends StatelessWidget {
  final String parkId;
  final String spaceId;
  final DateTime bookingDate;
  final TimeOfDay from;
  final TimeOfDay to;
  final VoidCallback onClick;
  final String? selectedSpace;

  const SpaceCard({
    super.key,
    required this.parkId,
    required this.spaceId,
    required this.bookingDate,
    required this.from,
    required this.to,
    required this.onClick,
    this.selectedSpace,
  });

  DateTime _convertTimeOfDayToDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  bool _isDateTimeOverlapping(DateTime start1, DateTime end1, DateTime start2,
      DateTime end2, DateTime date, String status) {
    if (date != bookingDate || status == "completed") {
      return false;
    } else {
      final start1InMinutes = start1.hour * 60 + start1.minute;
      final end1InMinutes = end1.hour * 60 + start1.minute;
      final start2InMinutes = start2.hour * 60 + start2.minute;
      final end2InMinutes = end2.hour * 60 + end2.minute;
      print("starts in $start1 start in2 $start2 end 1 $end1 end 2 $end2");
      // Check if time ranges overlap
      return start1InMinutes < end2InMinutes || start2InMinutes < end1InMinutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("bookings")
          .doc(parkId)
          .collection("slots")
          .where("slotId", isEqualTo: spaceId)
          .where("date", isEqualTo: Timestamp.fromDate(bookingDate))
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CardLoading(
              height: 30,
              width: 30,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          );
        }

        if (snapshot.hasData) {
          bool isBooked = false;
          DateTime fromDateTime =
              _convertTimeOfDayToDateTime(bookingDate, from);
          DateTime toDateTime = _convertTimeOfDayToDateTime(bookingDate, to);
          for (var doc in snapshot.data!.docs) {
            Booking booking = Booking.fromDocumentSnapshot(doc);
            DateTime bookingStart =
                _convertTimeOfDayToDateTime(booking.date, booking.fromTime);
            DateTime bookingEnd =
                _convertTimeOfDayToDateTime(booking.date, booking.toTime);
            if (_isDateTimeOverlapping(bookingStart, bookingEnd, fromDateTime,
                toDateTime, booking.date, booking.status)) {
              isBooked = true;
              print("is booked ${doc.id}");
              break;
            }
          }

          return InkWell(
            onTap: () {
              if (!isBooked) {
                onClick();
              }
            },
            child: Container(
              alignment: Alignment.center,
              color: selectedSpace == spaceId
                  ? kSelectedColor
                  : isBooked
                      ? kUnavailableColor
                      : kAvailableColor,
              child: Text(
                spaceId,
                style: TextStyle(color: Colors.grey[900]),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
