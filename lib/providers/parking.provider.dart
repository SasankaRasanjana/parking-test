import 'package:flutter/material.dart';
import 'package:parkme/models/parking.place.model.dart';

class ParkingProvider with ChangeNotifier {
  ParkingPlace? _selectedParkingPlace;
  ParkingPlace? get selectedParkingPlace => _selectedParkingPlace;

  set setParkingPlace(ParkingPlace place) {
    _selectedParkingPlace = place;
    notifyListeners();
  }
}
