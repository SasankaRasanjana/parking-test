import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkme/models/app.user.model.dart';
import 'package:parkme/models/parking.place.model.dart';
import 'package:parkme/models/payment.model.dart';
import 'package:parkme/services/parking.place.service.dart';
import 'package:parkme/utils/index.dart';

class OwnerEarningsView extends StatefulWidget {
  const OwnerEarningsView({super.key});

  @override
  State<OwnerEarningsView> createState() => _OwnerEarningsViewState();
}

class _OwnerEarningsViewState extends State<OwnerEarningsView> {
  ParkingPlace? place;
  final ParkingPlaceService _parkingPlaceService = ParkingPlaceService();

  @override
  void initState() {
    super.initState();
    _parkingPlaceService.getParkingPlacesByOwnerId().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          place = value.first;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Earnings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: place == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("payments")
                  .where("parkId", isEqualTo: place?.id)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No payments found"));
                }
                List<Payment> payments = snapshot.data!.docs
                    .map((doc) => Payment.fromDocumentSnapshot(doc))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    Payment payment = payments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("parkmeusers")
                                .doc(payment.userId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                if (snapshot.data!.exists) {
                                  AppUser user = AppUser.fromDocumentSnapshot(
                                      snapshot.data!);
                                  return Text("Payment from ${user.username}");
                                }
                              }
                              return Text("Payment from: ${payment.userId}");
                            }),
                        subtitle: Text(
                            "Check-in: ${payment.checkinTime.formatTime()}\nCheck-out: ${payment.checkoutTime.formatTime()}\n"),
                        trailing: Chip(
                          label: Text(
                            "Slot: ${payment.slotId}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.black,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
