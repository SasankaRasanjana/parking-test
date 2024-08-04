import 'package:flutter/material.dart';

class CustomSmallTitle extends StatelessWidget {
  final String subtitle;
  const CustomSmallTitle({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 18,
        color: Colors.grey[800],
      ),
    );
  }
}
