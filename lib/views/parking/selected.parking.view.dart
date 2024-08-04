import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:parkme/constants.dart';
import 'package:parkme/models/booking.model.dart';
import 'package:parkme/models/parking.place.model.dart';
import 'package:parkme/providers/home.provider.dart';
import 'package:parkme/providers/parking.provider.dart';
import 'package:parkme/services/booking.service.dart';
import 'package:parkme/utils/index.dart';
import 'package:parkme/widgets/custom.filled.button.dart';
import 'package:parkme/widgets/parling.card.dart';
import 'package:parkme/widgets/space.card.dart';
import 'package:provider/provider.dart';

class SelectedParkingView extends StatefulWidget {
  const SelectedParkingView({super.key});

  @override
  State<SelectedParkingView> createState() => _SelectedParkingViewState();
}

class _SelectedParkingViewState extends State<SelectedParkingView> {
  DateTime? selectedDate;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  String? selectedSpace;
  final _bookingService = BookingService();

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green, // Header background color
              onPrimary: Colors.white, // Header text color
              surface: Colors.white, // Background color
              onSurface: Colors.black, // Text color
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        if (isFromTime) {
          fromTime = pickedTime;
        } else {
          toTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    ParkingPlace? place = parkingProvider.selectedParkingPlace;

    return Scaffold(
      body: place == null
          ? const Center(
              child: Text("Please select a park"),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: kToolbarHeight),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: carParkImage,
                          fit: BoxFit.fill,
                        ),
                      ),
                      const Positioned(
                        left: 16,
                        child: DefaultTextStyle(
                          style: TextStyle(color: Colors.white),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: "Select your slot &\n",
                                    style: TextStyle(
                                      fontSize: 24,
                                    )),
                                TextSpan(
                                    text: "Book Here",
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ParkingCard(place: place),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    infoBox(Colors.white, "Available"),
                    infoBox(Colors.green, "Selected"),
                    infoBox(Colors.red, "Unavailable"),
                  ],
                ),
                const SizedBox(height: 16),
                if (selectedDate != null)
                  Center(
                    child: Text(
                      'Selected Date: ${selectedDate!.formatDate()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.green, // Header background color
                              onPrimary: Colors.white, // Header text color
                              surface: Colors.white, // Background color
                              onSurface: Colors.black, // Text color
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                      selectedDate != null ? "Change date" : 'Select Date'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          fromTime != null
                              ? 'From: ${fromTime!.format(context)}'
                              : 'Select From Time',
                          style: const TextStyle(fontSize: 16),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectTime(context, true),
                          child: const Text('Pick From Time'),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          toTime != null
                              ? 'To: ${toTime!.format(context)}'
                              : 'Select To Time',
                          style: const TextStyle(fontSize: 16),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectTime(context, false),
                          child: const Text('Pick To Time'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (selectedDate != null && fromTime != null && toTime != null)
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 30,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(child: Divider()),
                              Icon(Icons.car_repair),
                              Icon(Icons.bus_alert),
                              Expanded(child: Divider()),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Flexible(
                          flex: 2,
                          child: Row(
                            children: [
                              Expanded(child: Divider()),
                              Icon(Icons.motorcycle),
                              Expanded(child: Divider()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (selectedDate != null && fromTime != null && toTime != null)
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 1,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemCount: place.carSpaces,
                          itemBuilder: (context, index) {
                            return SpaceCard(
                              parkId: place.id,
                              spaceId: 'C:$index',
                              bookingDate: selectedDate!,
                              from: fromTime!,
                              to: toTime!,
                              selectedSpace: selectedSpace,
                              onClick: () {
                                setState(() {
                                  selectedSpace = "C:$index";
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Flexible(
                          flex: 2,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                            itemCount: place.bikeSpaces,
                            itemBuilder: (context, index) {
                              return SpaceCard(
                                parkId: place.id,
                                spaceId: 'B:$index',
                                bookingDate: selectedDate!,
                                from: fromTime!,
                                to: toTime!,
                                selectedSpace: selectedSpace,
                                onClick: () {
                                  setState(() {
                                    selectedSpace = "B:$index";
                                  });
                                },
                              );
                            },
                          ))
                    ],
                  ),
                if (selectedSpace != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: CustomButton(
                      text: "Confirm Booking",
                      onPressed: () {
                        Booking booking = Booking(
                            parkId: place.id,
                            userId:
                                FirebaseAuth.instance.currentUser?.uid ?? "",
                            slotId: selectedSpace!,
                            date: selectedDate!,
                            fromTime: fromTime!,
                            toTime: toTime!);
                        _bookingService.createBooking(booking).then((value) {
                          context.showSnackBar("Booking placed successfully");
                          homeProvider.setActiveIndex = 0;
                        }).catchError((error) {
                          context
                              .showSnackBar("Please try again, booking failed");
                        });
                      },
                    ),
                  )
              ],
            ),
    );
  }

  Row infoBox(Color color, String info) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(info),
      ],
    );
  }
}
