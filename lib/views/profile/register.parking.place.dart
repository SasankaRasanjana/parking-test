import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parkme/models/parking.place.model.dart';
import 'package:parkme/services/parking.place.service.dart';
import 'package:parkme/widgets/custom.filled.button.dart';
import 'package:parkme/widgets/custom.input.field.dart';

class RegisterParkingPlace extends StatefulWidget {
  const RegisterParkingPlace({super.key});

  @override
  State<RegisterParkingPlace> createState() => _RegisterParkingPlaceState();
}

class _RegisterParkingPlaceState extends State<RegisterParkingPlace> {
  final ParkingPlaceService _parkingPlaceService = ParkingPlaceService();
  final String ownerId = FirebaseAuth.instance.currentUser!.uid;
  final _key = GlobalKey<FormState>();
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

  Future<void> _registerParkingPlace() async {
    if (_key.currentState!.validate()) {
      if (_termsAccepted) {
        setState(() {
          _loading = true;
        });

        String? imageUrl;
        if (_pickedImage != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('parking_places/${_pickedImage!.name}');
          await storageRef.putFile(File(_pickedImage!.path));
          imageUrl = await storageRef.getDownloadURL();
        }

        ParkingPlace parkingPlace = ParkingPlace(
          id: '',
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
          const SnackBar(
              content: Text('Parking place registered successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please accept the terms and conditions')),
        );
      }
    }
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
        title: const Text('Register Parking Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _key,
          child: Column(
            children: [
              CustomInputField(
                label: 'Parking Space Name',
                hint: 'Enter parking space name',
                validator: (String? value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter a name for your parking space";
                  }
                  return null;
                },
                controller: _nameController,
              ),
              CustomInputField(
                label: 'City',
                hint: 'Enter city',
                validator: (String? value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter city";
                  }
                  return null;
                },
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
                validator: (String? value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter car/van spaces";
                  }
                  return null;
                },
                controller: _carSpacesController,
                inputType: TextInputType.number,
              ),
              CustomInputField(
                label: 'Emergency Spaces',
                hint: 'Enter number of emergency spaces',
                validator: (String? value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter emergency spaces";
                  }
                  return null;
                },
                controller: _emergencySpacesController,
                inputType: TextInputType.number,
              ),
              CustomInputField(
                label: 'Car/VAN Price',
                hint: 'Enter price for car/van',
                validator: (String? value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter car/van price";
                  }
                  return null;
                },
                controller: _carVanPriceController,
                inputType: TextInputType.number,
              ),
              CustomInputField(
                label: 'Bike Price',
                hint: 'Enter price for bike',
                validator: (String? value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter bike price";
                  }
                  return null;
                },
                controller: _bikePriceController,
                inputType: TextInputType.number,
              ),
              CustomInputField(
                label: 'Owner Name',
                hint: 'Enter owner name',
                validator: (String? value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter owner's full name";
                  }
                  return null;
                },
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
                validator: (String? value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter contact number";
                  }
                  return null;
                },
                controller: _ownerContactController,
                inputType: TextInputType.phone,
              ),
              CustomInputField(
                label: 'Owner Email',
                hint: 'Enter owner email',
                validator: (String? value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter email";
                  }
                  return null;
                },
                controller: _ownerEmailController,
                inputType: TextInputType.emailAddress,
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
                text: 'Register Parking Place',
                loading: _loading,
                onPressed: _registerParkingPlace,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
