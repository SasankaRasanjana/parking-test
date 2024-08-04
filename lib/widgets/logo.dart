import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: MediaQuery.of(context).size.width / 3,
      backgroundColor: Colors.white,
      backgroundImage: const AssetImage("assets/logo.png"),
    );
  }
}
