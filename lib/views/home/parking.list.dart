import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkme/constants.dart';
import 'package:parkme/models/parking.place.model.dart';
import 'package:parkme/widgets/custom.search.bar.dart';
import 'package:parkme/widgets/parling.card.dart';

class ParkingList extends StatefulWidget {
  const ParkingList({super.key});

  @override
  State<ParkingList> createState() => _ParkingListState();
}

class _ParkingListState extends State<ParkingList> {
  final searchController = TextEditingController();
  String searchQuery = "";
  List<ParkingPlace> allParkingPlaces = [];
  List<ParkingPlace> filteredParkingPlaces = [];

  @override
  void initState() {
    super.initState();
    fetchParkingPlaces();
  }

  void fetchParkingPlaces() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("parkingPlaces").get();
    setState(() {
      allParkingPlaces = snapshot.docs
          .map((doc) => ParkingPlace.fromDocumentSnapshot(doc))
          .toList();
      filteredParkingPlaces = allParkingPlaces;
    });
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredParkingPlaces = allParkingPlaces
          .where((place) =>
              place.city.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(
            height: 32,
          ),
          const HomeTitle(),
          const SizedBox(
            height: 16,
          ),
          CustomSearchField(
            controller: searchController,
            onChanged: onSearch,
          ),
          Expanded(
            child: filteredParkingPlaces.isEmpty
                ? const Center(
                    child: Text("No parking places at the moment"),
                  )
                : ListView(
                    children: filteredParkingPlaces
                        .map((e) => ParkingCard(place: e))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class HomeTitle extends StatelessWidget {
  const HomeTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: carParkImage,
              fit: BoxFit.fitWidth,
            ),
          ),
          const Positioned(
            left: 26,
            top: 15,
            child: DefaultTextStyle(
              style: TextStyle(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Looking for",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    "Parking Space ?",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
