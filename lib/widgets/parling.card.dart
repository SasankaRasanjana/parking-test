import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:parkme/models/parking.place.model.dart';
import 'package:parkme/providers/home.provider.dart';
import 'package:parkme/providers/parking.provider.dart';
import 'package:parkme/widgets/park.price.column.dart';
import 'package:provider/provider.dart';

class ParkingCard extends StatelessWidget {
  final ParkingPlace place;
  const ParkingCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    return InkWell(
      onTap: () {
        parkingProvider.setParkingPlace = place;
        homeProvider.setActiveIndex = 2;
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: place.imageUrl,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on),
                    Text(
                      place.city,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
                ParkPriceColumn(
                    carVanPrice: place.carVanPrice, bikePrice: place.bikePrice)
              ],
            )),
          ],
        ),
      ),
    );
  }
}
