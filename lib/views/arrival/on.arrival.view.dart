import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/constants.dart';
import 'package:parkme/models/booking.model.dart';
import 'package:parkme/services/booking.service.dart';
import 'package:parkme/utils/index.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

class OnArrivalView extends StatefulWidget {
  const OnArrivalView({super.key});

  @override
  State<OnArrivalView> createState() => _OnArrivalViewState();
}

class _OnArrivalViewState extends State<OnArrivalView> {
  final BookingService _bookingService = BookingService();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 48,
            ),
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              flex: 4,
              child: Center(
                child: (result != null)
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("bookings")
                            .doc(result!.code)
                            .collection("slots")
                            .where("userId",
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return const SizedBox();
                          }
                          List<Booking> bookings = [];
                          if (snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text("No results"),
                            );
                          }
                          bookings = snapshot.data!.docs
                              .map((e) => Booking.fromDocumentSnapshot(e))
                              .toList()
                              .where((element) =>
                                  (element.status == "pending" ||
                                      element.status == "ongoing"))
                              .toList();
                          if (bookings.isEmpty) {
                            return const Center(
                              child: Text("No results"),
                            );
                          }
                          Booking booking = bookings.first;
                          booking.setStatus = "ongoing";
                          _bookingService.updateBooking(booking);
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ]),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Parking Information",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 16,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Selected Slot",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        booking.slotId,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Check In Time",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Chip(
                                        backgroundColor: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          side: BorderSide.none,
                                        ),
                                        label: Text(
                                          DateTime.now().formatTime(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Selected Vehicle Type:",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Container(
                                        width: 60,
                                        decoration: BoxDecoration(
                                            color: secondoryGreen,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        height: 60,
                                        child: Icon(
                                          size: 48,
                                          booking.slotId.contains("C")
                                              ? Icons.car_rental
                                              : Icons.motorcycle,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        })
                    : const Text('Scan a code'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
