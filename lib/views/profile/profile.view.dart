import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:parkme/models/app.user.model.dart';
import 'package:parkme/models/parking.place.model.dart';
import 'package:parkme/services/app.user.service.dart';
import 'package:parkme/services/auth.service.dart';
import 'package:parkme/utils/index.dart';
import 'package:parkme/views/auth/login.view.dart';
import 'package:parkme/views/owner/owner.bookings.view.dart';
import 'package:parkme/views/owner/owner.earnings.view.dart';
import 'package:parkme/views/profile/panalties.view.dart';
import 'package:parkme/views/profile/register.parking.place.dart';
import 'package:parkme/views/profile/update.parking.space.view.dart';
import 'package:parkme/widgets/custom.filled.button.dart';
import 'package:parkme/widgets/custom.input.field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_image_generator/qr_image_generator.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AppUserService _userService = AppUserService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  Future<void> saveQRImage() async {
    try {
      final generator = QRGenerator();
      final fPath = await filePath();

      if (fPath == null || fPath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid file path')),
        );
        return;
      }
      await generator.generate(
        data: '${FirebaseAuth.instance.currentUser?.uid}',
        filePath: fPath,
        scale: 10,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        errorCorrectionLevel: ErrorCorrectionLevel.medium,
        qrVersion: 4,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving QR code: $e')),
      );
    }
  }

  Future<String?> filePath() async {
    final directory = await getApplicationDocumentsDirectory();

    return '${directory.path}/parkQR.png';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    AppUser? user = await _userService.getUser();
    if (user != null) {
      setState(() {
        _emailController.text = user.email;
        _usernameController.text = user.username;
        _roleController.text = user.role;
      });
    }
  }

  Future<void> _updateUser() async {
    AppUser user = AppUser(
      email: _emailController.text,
      username: _usernameController.text,
      role: _roleController.text,
    );

    await _userService.setUser(user);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Future<void> _deleteUser() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Do you want to logout ?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No"),
                ),
                TextButton(
                  onPressed: () async {
                    await AuthService()
                        .signOut()
                        .then(
                          (value) => context.navigator(context, LoginView(),
                              shouldBack: false),
                        )
                        .onError((error, stackTrace) =>
                            context.showSnackBar("Error while signin in"));
                  },
                  child: const Text("Yes"),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _deleteUser,
            icon: const Icon(Icons.logout_sharp),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('points')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data?.data() == null) {
                      return Text("Total Points : 0");
                    } else {
                      final data =
                          snapshot.data?.data() as Map<String, dynamic>;
                      return Text("Total Points : ${data['points']}");
                    }
                  } else {
                    return Text("Total Points : 0");
                  }
                }),
            CustomInputField(
              enabled: false,
              controller: _emailController,
              label: "Email",
              hint: "email",
            ),
            CustomInputField(
              controller: _usernameController,
              label: "Username",
              hint: "username",
            ),
            const SizedBox(height: 20),
            CustomButton(onPressed: _updateUser, text: 'Update Profile'),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("parkingPlaces")
                    .where("ownerId",
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    if (snapshot.data!.docs.isNotEmpty) {
                      ParkingPlace place = ParkingPlace.fromDocumentSnapshot(
                          snapshot.data!.docs.first);
                      return Column(
                        children: [
                          CustomButton(
                              text: "Check parking space",
                              onPressed: () {
                                context.navigator(
                                    context,
                                    UpdateParkingPlace(
                                        parkingPlaceId: FirebaseAuth
                                            .instance.currentUser!.uid));
                              }),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomButton(
                              text: "Bookings",
                              onPressed: () {
                                context.navigator(
                                    context, const OwnerBookingsView());
                              }),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomButton(
                              text: "Earnings",
                              onPressed: () {
                                context.navigator(
                                    context, const OwnerEarningsView());
                              }),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomButton(
                              text: "Panalties",
                              onPressed: () {
                                context.navigator(
                                    context, PanaltiesView(place: place));
                              }),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomButton(
                              text: "Share Place QR",
                              onPressed: () {
                                saveQRImage();
                                saveQRImage().then((value) => showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            constraints: const BoxConstraints(
                                              maxHeight: 400,
                                            ),
                                            child: FutureBuilder(
                                                future: filePath(),
                                                builder: (context,
                                                    AsyncSnapshot<String?>
                                                        snapshot) {
                                                  if (snapshot.data == null) {
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                                                  return Image.file(
                                                    File(snapshot.data!),
                                                    fit: BoxFit.cover,
                                                  );
                                                })),
                                      ),
                                    ));
                              }),
                        ],
                      );
                    }
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Want to become an owner ?"),
                      TextButton(
                        onPressed: () {
                          context.navigator(
                              context, const RegisterParkingPlace());
                        },
                        child: const Text("Become owner"),
                      ),
                    ],
                  );
                }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _roleController.dispose();
    super.dispose();
  }
}
