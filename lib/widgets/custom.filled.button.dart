import 'package:flutter/material.dart';
import 'package:parkme/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final double width;
  final bool loading;
  const CustomButton({
    Key? key,
    required this.text,
    this.loading = false,
    required this.onPressed,
    this.color = secondoryGreen,
    this.textColor = Colors.white,
    this.borderRadius = 30.0,
    this.width = 600.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              width: width,
              padding: padding,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Center(
                child: Text(
                  text,
                  style:
                      textStyle ?? TextStyle(color: textColor, fontSize: 16.0),
                ),
              ),
            ),
          );
  }
}
