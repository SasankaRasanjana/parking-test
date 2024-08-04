import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingPlace {
  final String id;
  final String ownerId;
  final String name;
  final String city;
  final int bikeSpaces;
  final int carSpaces;
  final int emergencySpaces;
  final String ownerName;
  final String ownerAddress;
  final String ownerContact;
  final String ownerEmail;
  final bool termsAccepted;
  final String imageUrl;
  final double carVanPrice;
  final double bikePrice;

  ParkingPlace({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.city,
    required this.bikeSpaces,
    required this.carSpaces,
    required this.emergencySpaces,
    required this.ownerName,
    required this.ownerAddress,
    required this.ownerContact,
    required this.ownerEmail,
    required this.termsAccepted,
    this.imageUrl =
        'https://images.unsplash.com/photo-1588362951121-3ee319b018b2?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    required this.carVanPrice,
    required this.bikePrice,
  });

  factory ParkingPlace.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ParkingPlace(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      bikeSpaces: data['bikeSpaces'] ?? 0,
      carSpaces: data['carSpaces'] ?? 0,
      emergencySpaces: data['emergencySpaces'] ?? 0,
      ownerName: data['ownerName'] ?? '',
      ownerAddress: data['ownerAddress'] ?? '',
      ownerContact: data['ownerContact'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      termsAccepted: data['termsAccepted'] ?? false,
      imageUrl: data['imageUrl'] ??
          'https://images.unsplash.com/photo-1588362951121-3ee319b018b2?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      carVanPrice: (data['carVanPrice'] as num?)?.toDouble() ?? 0.0,
      bikePrice: (data['bikePrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'city': city,
      'bikeSpaces': bikeSpaces,
      'carSpaces': carSpaces,
      'emergencySpaces': emergencySpaces,
      'ownerName': ownerName,
      'ownerAddress': ownerAddress,
      'ownerContact': ownerContact,
      'ownerEmail': ownerEmail,
      'termsAccepted': termsAccepted,
      'imageUrl': imageUrl,
      'carVanPrice': carVanPrice,
      'bikePrice': bikePrice,
    };
  }
}
