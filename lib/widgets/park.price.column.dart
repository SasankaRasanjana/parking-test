import 'package:flutter/material.dart';

class ParkPriceColumn extends StatelessWidget {
  final double carVanPrice;
  final double bikePrice;

  const ParkPriceColumn({
    super.key,
    required this.carVanPrice,
    required this.bikePrice,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current day of the week
    DateTime now = DateTime.now();
    bool isWeekend =
        now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    // Increase the prices by 20% if today is Saturday or Sunday
    double adjustedCarVanPrice = isWeekend ? carVanPrice * 1.2 : carVanPrice;
    double adjustedBikePrice = isWeekend ? bikePrice * 1.2 : bikePrice;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.car_rental),
            Text("LKR: ${adjustedCarVanPrice.toStringAsFixed(2)} / Hr"),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.motorcycle),
            Text("LKR: ${adjustedBikePrice.toStringAsFixed(2)} / Hr"),
          ],
        ),
      ],
    );
  }
}
