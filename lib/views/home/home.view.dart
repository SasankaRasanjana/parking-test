import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:parkme/constants.dart';
import 'package:parkme/models/booking.model.dart';
import 'package:parkme/providers/home.provider.dart';
import 'package:parkme/utils/index.dart';
import 'package:parkme/views/arrival/on.arrival.view.dart';
import 'package:parkme/views/bookings/my.bookings.view.dart';
import 'package:parkme/views/home/parking.list.dart';
import 'package:parkme/views/parking/selected.parking.view.dart';
import 'package:parkme/views/payments/make.payment.view.dart';
import 'package:parkme/views/profile/profile.view.dart';
import 'package:parkme/widgets/custom.filled.button.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<IconData> get iconList => [
        Icons.home,
        Icons.menu,
        Icons.alarm,
        Icons.person,
      ];

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> hasBooking = ValueNotifier<bool>(false);
    final homeProvider = Provider.of<HomeProvider>(context);
    Widget homeBody() {
      switch (homeProvider.activeIndex) {
        case 0:
          return const ParkingList();
        case 2:
          return const SelectedParkingView();
        case 1:
          return const MyBookingsView();
        case 3:
          return const ProfileView();
        case 4:
          return const OnArrivalView();
        default:
          return Container();
      }
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("ongoingBookings")
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              if (snapshot.data!.exists) {
                if ((snapshot.data!.data() as Map)["status"] == "ongoing") {
                  hasBooking.value = true;
                  Booking booking =
                      Booking.fromDocumentSnapshot(snapshot.data!);
                  final checkedInTime = ((snapshot.data!.data()
                          as Map)["checkinTime"] as Timestamp)
                      .toDate();
                  return OngoinParkinngAlertView(
                      booking: booking,
                      checkedInTime: checkedInTime,
                      bookingId:
                          (snapshot.data!.data() as Map)["bookingId"] ?? "");
                }
              }
              hasBooking.value = false;
              return homeBody();
            }
            return const Center(
              child: Text("Loding...."),
            );
          }),
      floatingActionButton: ValueListenableBuilder<bool>(
          valueListenable: hasBooking,
          builder: (context, value, child) {
            return value
                ? const SizedBox.shrink()
                : FloatingActionButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    backgroundColor: Colors.teal,
                    onPressed: () {
                      homeProvider.setActiveIndex = 4;
                    },
                    child: const Icon(Icons.add),
                  );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: hasBooking,
          builder: (context, value, child) {
            return value
                ? const SizedBox.shrink()
                : AnimatedBottomNavigationBar(
                    backgroundColor: Colors.black,
                    leftCornerRadius: 12,
                    rightCornerRadius: 12,
                    icons: iconList,
                    activeIndex: homeProvider.activeIndex,
                    activeColor: Colors.teal,
                    inactiveColor: Colors.grey,
                    gapLocation: GapLocation.center,
                    notchSmoothness: NotchSmoothness.defaultEdge,
                    onTap: (index) =>
                        setState(() => homeProvider.setActiveIndex = index),
                  );
          }),
    );
  }
}

class OngoinParkinngAlertView extends StatefulWidget {
  const OngoinParkinngAlertView({
    super.key,
    required this.booking,
    required this.checkedInTime,
    required this.bookingId,
  });

  final Booking booking;
  final DateTime checkedInTime;
  final String bookingId;

  @override
  _OngoinParkinngAlertViewState createState() =>
      _OngoinParkinngAlertViewState();
}

class _OngoinParkinngAlertViewState extends State<OngoinParkinngAlertView> {
  late Timer _timer;
  late Duration _elapsedTime;

  @override
  void initState() {
    super.initState();
    _elapsedTime = DateTime.now().difference(widget.checkedInTime);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(widget.checkedInTime);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
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
                  height: 32,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        widget.booking.slotId,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide.none,
                        ),
                        label: Text(
                          DateFormat('hh:mm a').format(widget.checkedInTime),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12)),
                        height: 60,
                        child: Icon(
                          size: 48,
                          widget.booking.slotId.contains("C")
                              ? Icons.car_rental
                              : Icons.motorcycle,
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(),
                const Text(
                  "Elapsed Time",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _formatDuration(_elapsedTime),
                  style: const TextStyle(
                    fontSize: 20,
                    color: secondoryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                const Divider(),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Booking Ends At",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        formatTime(widget.booking.toTime.hour,
                            widget.booking.toTime.minute),
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                CustomButton(
                  text: "Complete",
                  onPressed: () {
                    context.navigator(
                        context,
                        MakePaymentView(
                          bookingId: widget.bookingId,
                          booking: widget.booking,
                          checkinTime: widget.checkedInTime,
                          checkoutTime: DateTime.now(),
                        ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatTime(int hour, int minute) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, hour, minute);
    final formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }
}
