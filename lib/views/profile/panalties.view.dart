import 'package:flutter/material.dart';
import 'package:parkme/models/panalty.model.dart';
import 'package:parkme/models/parking.place.model.dart';
import 'package:parkme/services/panalty.service.dart';
import 'package:parkme/widgets/main.container.dart';

class PanaltiesView extends StatelessWidget {
  final ParkingPlace place;
  const PanaltiesView({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    String parkId = place.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Panalties",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: const BackButton(
          color: Colors.white,
        ),
      ),
      body: MainContainer(
        child: StreamBuilder<List<Penalty>>(
          stream: PenaltyService().getPenaltiesByParkId(parkId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No penalties found.'));
            } else {
              final penalties = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: penalties.length,
                itemBuilder: (context, index) {
                  final penalty = penalties[index];
                  return Card(
                    child: ListTile(
                      title: Text('Amount: ${penalty.price}'),
                      subtitle: Text('Reason: ${penalty.reason}'),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
