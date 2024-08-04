import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parkme/models/parking.place.model.dart';
import 'package:parkme/services/parking.place.service.dart';
import 'package:parkme/widgets/custom.filled.button.dart';
import 'package:parkme/widgets/custom.input.field.dart';

class UpdateParkingPlace extends StatefulWidget {
  final String parkingPlaceId;

  const UpdateParkingPlace({super.key, required this.parkingPlaceId});

  @override
  State<UpdateParkingPlace> createState() => _UpdateParkingPlaceState();
}

class _UpdateParkingPlaceState extends State<UpdateParkingPlace> {
  final ParkingPlaceService _parkingPlaceService = ParkingPlaceService();
  final String ownerId = FirebaseAuth.instance.currentUser!.uid;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bikeSpacesController = TextEditingController();
  final TextEditingController _carSpacesController = TextEditingController();
  final TextEditingController _emergencySpacesController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerAddressController = TextEditingController();
  final TextEditingController _ownerContactController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _carVanPriceController = TextEditingController();
  final TextEditingController _bikePriceController = TextEditingController();
  bool _termsAccepted = false;
  bool _loading = false;
  XFile? _pickedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadParkingPlaceData();
  }

  Future<void> _loadParkingPlaceData() async {
    ParkingPlace? parkingPlace =
        await _parkingPlaceService.getParkingPlaceById(widget.parkingPlaceId);
    if (parkingPlace != null) {
      setState(() {
        _nameController.text = parkingPlace.name;
        _cityController.text = parkingPlace.city;
        _bikeSpacesController.text = parkingPlace.bikeSpaces.toString();
        _carSpacesController.text = parkingPlace.carSpaces.toString();
        _emergencySpacesController.text =
            parkingPlace.emergencySpaces.toString();
        _ownerNameController.text = parkingPlace.ownerName;
        _ownerAddressController.text = parkingPlace.ownerAddress;
        _ownerContactController.text = parkingPlace.ownerContact;
        _ownerEmailController.text = parkingPlace.ownerEmail;
        _carVanPriceController.text = parkingPlace.carVanPrice.toString();
        _bikePriceController.text = parkingPlace.bikePrice.toString();
        _termsAccepted = parkingPlace.termsAccepted;
        _imageUrl = parkingPlace.imageUrl;
      });
    }
  }

  Future<void> _updateParkingPlace() async {
    setState(() {
      _loading = true;
    });

    String? imageUrl = _imageUrl;
    if (_pickedImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('parking_places/${_pickedImage!.name}');
      await storageRef.putFile(File(_pickedImage!.path));
      imageUrl = await storageRef.getDownloadURL();
    }

    ParkingPlace parkingPlace = ParkingPlace(
      id: widget.parkingPlaceId,
      ownerId: ownerId,
      name: _nameController.text,
      city: _cityController.text,
      bikeSpaces: int.tryParse(_bikeSpacesController.text) ?? 0,
      carSpaces: int.tryParse(_carSpacesController.text) ?? 0,
      emergencySpaces: int.tryParse(_emergencySpacesController.text) ?? 0,
      ownerName: _ownerNameController.text,
      ownerAddress: _ownerAddressController.text,
      ownerContact: _ownerContactController.text,
      ownerEmail: _ownerEmailController.text,
      termsAccepted: _termsAccepted,
      imageUrl: imageUrl ??
          "'https://images.unsplash.com/photo-1588362951121-3ee319b018b2?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      carVanPrice: double.tryParse(_carVanPriceController.text) ?? 0.0,
      bikePrice: double.tryParse(_bikePriceController.text) ?? 0.0,
    );

    await _parkingPlaceService.setParkingPlace(parkingPlace);

    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Parking place updated successfully')),
    );

    // Navigate or perform other actions after successful update
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _pickedImage = image;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _bikeSpacesController.dispose();
    _carSpacesController.dispose();
    _emergencySpacesController.dispose();
    _ownerNameController.dispose();
    _ownerAddressController.dispose();
    _ownerContactController.dispose();
    _ownerEmailController.dispose();
    _carVanPriceController.dispose();
    _bikePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Parking Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomInputField(
              label: 'Parking Space Name',
              hint: 'Enter parking space name',
              controller: _nameController,
            ),
            CustomInputField(
              label: 'City',
              hint: 'Enter city',
              controller: _cityController,
            ),
            CustomInputField(
              label: 'Bike Spaces',
              hint: 'Enter number of bike spaces',
              controller: _bikeSpacesController,
              inputType: TextInputType.number,
            ),
            CustomInputField(
              label: 'Car/VAN Spaces',
              hint: 'Enter number of car/van spaces',
              controller: _carSpacesController,
              inputType: TextInputType.number,
            ),
            CustomInputField(
              label: 'Emergency Spaces',
              hint: 'Enter number of emergency spaces',
              controller: _emergencySpacesController,
              inputType: TextInputType.number,
            ),
            CustomInputField(
              label: 'Car/VAN Price',
              hint: 'Enter price for car/van',
              controller: _carVanPriceController,
              inputType: TextInputType.number,
            ),
            CustomInputField(
              label: 'Bike Price',
              hint: 'Enter price for bike',
              controller: _bikePriceController,
              inputType: TextInputType.number,
            ),
            CustomInputField(
              label: 'Owner Name',
              hint: 'Enter owner name',
              controller: _ownerNameController,
            ),
            CustomInputField(
              label: 'Owner Address',
              hint: 'Enter owner address',
              controller: _ownerAddressController,
            ),
            CustomInputField(
              label: 'Owner Contact',
              hint: 'Enter owner contact number',
              controller: _ownerContactController,
              inputType: TextInputType.phone,
            ),
            CustomInputField(
              label: 'Owner Email',
              hint: 'Owner email',
              controller: _ownerEmailController,
              inputType: TextInputType.emailAddress,
              enabled: false,
            ),
            Row(
              children: [
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value!;
                    });
                  },
                ),
                const Expanded(
                  child: Text('I accept the terms and conditions'),
                ),
              ],
            ),
            if (_pickedImage != null)
              Image.file(
                File(_pickedImage!.path),
                height: 150,
              ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick an Image'),
            ),
            CustomButton(
              text: 'Update Parking Place',
              loading: _loading,
              onPressed: _updateParkingPlace,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
