import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkme/models/booking.model.dart';
import 'package:parkme/models/parking.place.model.dart';
import 'package:parkme/services/parking.place.service.dart';
import 'package:parkme/utils/index.dart';

class OwnerBookingsView extends StatefulWidget {
  const OwnerBookingsView({super.key});

  @override
  State<OwnerBookingsView> createState() => _OwnerBookingsViewState();
}

class _OwnerBookingsViewState extends State<OwnerBookingsView> {
  ParkingPlace? parkingPlace;

  final ParkingPlaceService _parkingPlaceService = ParkingPlaceService();

  @override
  void initState() {
    _parkingPlaceService
        .getParkingPlacesByOwnerId()
        .then((value) => setState(() {
              if (value.isNotEmpty) {
                parkingPlace = value.first;
              }
            }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: const Text(
          "Bookings",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (parkingPlace != null)
              Card(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Place name  : ${parkingPlace!.name}",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text("Location  : ${parkingPlace!.city}"),
                    ],
                  ),
                ),
              ),
            if (parkingPlace != null)
              Text(
                "Bookings",
                style: TextStyle(
                    color: Colors.grey[800]!,
                    fontWeight: FontWeight.w800,
                    fontSize: 24),
              ),
            if (parkingPlace != null)
              Expanded(
                  child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("bookings")
                    .doc(parkingPlace?.id)
                    .collection("slots")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    List<Booking> bookings = snapshot.data!.docs
                        .map((e) => Booking.fromDocumentSnapshot(e))
                        .toList();
                    return ListView(
                      children: bookings
                          .map(
                            (e) => Card(
                              child: ListTile(
                                title: Text(e.slotId),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${e.date.formatDate()} ${DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                      e.fromTime.hour,
                                      e.fromTime.minute,
                                    ).formatTime()}"),
                                    Chip(
                                      label: Text(
                                        e.status,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ))
          ],
        ),
      ),
    );
  }
}
