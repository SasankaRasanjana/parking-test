import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/models/booking.model.dart';
import 'package:parkme/models/parking.place.model.dart';
import 'package:parkme/services/booking.service.dart';
import 'package:parkme/utils/index.dart';
import 'package:parkme/views/feedbacks/give.feedbacks.view.dart';

class MyBookingsView extends StatelessWidget {
  const MyBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "My Bookings",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("bookings").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshots) {
            if (snapshots.data != null) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: snapshots.data!.docs
                    .map((e) => StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("bookings")
                            .doc(e.id)
                            .collection("slots")
                            .where("userId",
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.data != null) {
                            List<Booking> bookings = snapshot.data!.docs
                                .map((e) => Booking.fromDocumentSnapshot(e))
                                .toList();
                            return Column(
                              children: bookings
                                  .map(
                                    (e) => SizedBox(
                                      height: 100,
                                      child: StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection("parkingPlaces")
                                              .doc(e.parkId)
                                              .snapshots(),
                                          builder: (context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshot) {
                                            if (snapshot.data != null) {
                                              ParkingPlace place = ParkingPlace
                                                  .fromDocumentSnapshot(
                                                      snapshot.data!);
                                              return Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.white),
                                                margin: const EdgeInsets.only(
                                                    bottom: 6),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: CachedNetworkImage(
                                                        width: 100,
                                                        height: 100,
                                                        imageUrl:
                                                            place.imageUrl,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 16,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Text(
                                                            place.name,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[700],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 14),
                                                          ),
                                                          Text(e.date
                                                              .formatDate()),
                                                          e.status ==
                                                                  "completed"
                                                              ? Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Chip(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                                50)),
                                                                        backgroundColor:
                                                                            Colors
                                                                                .green,
                                                                        side: BorderSide
                                                                            .none,
                                                                        label:
                                                                            const Text(
                                                                          "Completed",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        )),
                                                                    const SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        context.navigator(
                                                                            context,
                                                                            GiveFeedbackView(booking: e));
                                                                      },
                                                                      child: Chip(
                                                                          shape: RoundedRectangleBorder(side: BorderSide(width: 2, color: Colors.grey[900]!), borderRadius: BorderRadius.circular(50)),
                                                                          side: BorderSide.none,
                                                                          label: Text(
                                                                            "Review",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.grey[700],
                                                                            ),
                                                                          )),
                                                                    ),
                                                                  ],
                                                                )
                                                              : Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                        "Status : ${e.status.toUpperCase()}"),
                                                                    if (e.status ==
                                                                        "pending")
                                                                      ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) => AlertDialog(
                                                                                    title: const Text(
                                                                                      "Are u want to cancel this booking?",
                                                                                      style: TextStyle(
                                                                                        fontSize: 18,
                                                                                      ),
                                                                                    ),
                                                                                    actions: [
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: const Text("No"),
                                                                                      ),
                                                                                      TextButton(
                                                                                        onPressed: () async {
                                                                                          e.setStatus = "cancelled";
                                                                                          await bookingService.updateBooking(e, status: "cancelled");
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: const Text("Yes"),
                                                                                      ),
                                                                                    ],
                                                                                  ));
                                                                        },
                                                                        child: const Text(
                                                                            "Cancel"),
                                                                      ),
                                                                    const SizedBox(
                                                                      width: 8,
                                                                    )
                                                                  ],
                                                                ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }),
                                    ),
                                  )
                                  .toList(),
                            );
                          }
                          return const SizedBox.shrink();
                        }))
                    .toList(),
              );
            }
            return const SizedBox.shrink();
          }),
    );
  }
}
