import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/models/booking.model.dart';
import 'package:parkme/models/parking.place.model.dart';
import 'package:parkme/services/booking.service.dart';
import 'package:parkme/services/parking.place.service.dart';
import 'package:parkme/services/points.service.dart';
import 'package:parkme/utils/index.dart';
import 'package:parkme/views/home/home.view.dart';
import 'package:parkme/widgets/custom.filled.button.dart';
import 'package:parkme/widgets/custom.input.field.dart';

class MakePaymentView extends StatefulWidget {
  final Booking booking;
  final DateTime checkinTime;
  final String bookingId;
  final DateTime checkoutTime;
  const MakePaymentView(
      {super.key,
      required this.booking,
      required this.bookingId,
      required this.checkinTime,
      required this.checkoutTime});

  @override
  State<MakePaymentView> createState() => _MakePaymentViewState();
}

class _MakePaymentViewState extends State<MakePaymentView> {
  int totalPoints = 0;
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _couponController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  String _selectedCardType = 'Visa';
  int usedPoints = 0;
  bool pointsApplied = false;
  ParkingPlace? parkingPlace;
  final ParkingPlaceService _parkingPlaceService = ParkingPlaceService();

  @override
  void initState() {
    _parkingPlaceService
        .getParkingPlaceById(widget.booking.parkId)
        .then((value) => setState(() {
              parkingPlace = value;
            }))
        .catchError((onError) {
      context.showSnackBar("Error getting details");
    });
    PointsService().getUsersPoints().then((value) => setState(() {
          totalPoints = value;
        }));
    super.initState();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return MonthYearPicker(initialDate: initialDate);
      },
    );
    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        _expiryDateController.text =
            '${pickedDate.month}/${pickedDate.year % 100}';
      });
    }
  }

  double calculateTotalBill() {
    if (parkingPlace != null) {
      double unitPrice = widget.booking.slotId.contains("C")
          ? parkingPlace!.carVanPrice
          : parkingPlace!.bikePrice;
      DateTime currentTime = widget.checkoutTime;
      DateTime checkinTime = widget.checkinTime;

      // Calculate the duration of parking in minutes
      double durationInMinutes =
          currentTime.difference(checkinTime).inMinutes.toDouble();

      // Calculate the total bill based on the duration in minutes
      double totalBill = (durationInMinutes / 60) * unitPrice;
      if (pointsApplied) {
        totalBill = totalBill - (int.parse(_couponController.text) / 100);
      }
      return totalBill;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text(
          'Make Payment',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: parkingPlace == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 32,
                    ),
                    Center(
                      child: Text(
                        "Total bill LKR.${calculateTotalBill().toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Center(
                        child: Text(
                      "You have $totalPoints points",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600]!),
                    )),
                    const SizedBox(
                      height: 32,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 32,
                    ),
                    if (totalPoints > 0)
                      SizedBox(
                        height: kToolbarHeight * 2,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomInputField(
                                label: "Enter num of points you want to apply",
                                hint: "0",
                                controller: _couponController,
                                inputType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            MaterialButton(
                              color: Colors.black,
                              height: kToolbarHeight,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: () {
                                if (_couponController.text.isNotEmpty) {
                                  FocusScope.of(context).unfocus();
                                  if (int.parse(_couponController.text) <=
                                      totalPoints) {
                                    setState(() {
                                      pointsApplied = true;
                                      totalPoints = totalPoints -
                                          int.parse(_couponController.text);
                                      usedPoints =
                                          int.parse(_couponController.text);
                                    });
                                    context.showSnackBar(
                                        "Points applied successfully");
                                  } else {
                                    context.showSnackBar(
                                        "Please enter valid num of points");
                                  }
                                }
                              },
                              child: const Text(
                                "Apply",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (totalPoints > 0) const Divider(),
                    if (totalPoints > 0)
                      const SizedBox(
                        height: 32,
                      ),
                    DropdownButtonFormField<String>(
                      value: _selectedCardType,
                      decoration: const InputDecoration(
                        labelText: 'Card Type',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      items: ['Visa', 'Mastercard'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCardType = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        hintText: '1234 5678 9012 3456',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your card number';
                        }
                        // Regex for validating credit card number
                        final regex = RegExp(r'^[0-9]{16}$');
                        if (!regex.hasMatch(value)) {
                          return 'Please enter a valid 16-digit card number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryDateController,
                            keyboardType: TextInputType.datetime,
                            decoration: const InputDecoration(
                              labelText: 'Expiry Date',
                              hintText: 'MM/YY',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectExpiryDate(context);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter expiry date';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter CVV';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cardHolderNameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        labelText: 'Card Holder Name',
                        hintText: 'John Doe',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card holder name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: CustomButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final data = {
                              "checkinTime": widget.checkinTime,
                              "checkoutTime": widget.checkoutTime,
                              "userId": FirebaseAuth.instance.currentUser?.uid,
                              ...widget.booking.toMap(),
                            };
                            await BookingService()
                                .updateBookingStatus(
                                    widget.bookingId, widget.booking.parkId)
                                .then((value) => FirebaseFirestore.instance
                                    .collection("payments")
                                    .doc()
                                    .set(data))
                                .then((value) async {
                              await PointsService().addOrUpdatePoints(
                                  (calculateTotalBill() ~/ 100));
                              await PointsService()
                                  .reduceUsedPoints(usedPoints);
                            }).then((value) {
                              context
                                  .showSnackBar("Thank you for your payment");
                              context.navigator(context, const HomeView());
                            }).catchError((err) {
                              context.showSnackBar(
                                  "Error paying the payment, try again");
                            });
                          }
                        },
                        text: "Pay Now",
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class MonthYearPicker extends StatefulWidget {
  final DateTime initialDate;

  const MonthYearPicker({required this.initialDate});

  @override
  _MonthYearPickerState createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialDate.month;
    selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Expiry Date'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            value: selectedMonth,
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text('${index + 1}'),
              );
            }),
            onChanged: (value) {
              setState(() {
                selectedMonth = value!;
              });
            },
          ),
          DropdownButton<int>(
            value: selectedYear,
            items: List.generate(20, (index) {
              return DropdownMenuItem(
                value: DateTime.now().year + index,
                child: Text('${DateTime.now().year + index}'),
              );
            }),
            onChanged: (value) {
              setState(() {
                selectedYear = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(DateTime(selectedYear, selectedMonth));
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
