import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final bool enabled;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.inputType = TextInputType.text,
    this.isPassword = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.onFieldSubmitted,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: labelStyle ?? Theme.of(context).textTheme.bodyText1,
            ),
          TextFormField(
            controller: controller,
            keyboardType: inputType,
            obscureText: isPassword,
            validator: validator,
            enabled: enabled,
            textInputAction: textInputAction,
            focusNode: focusNode,
            onFieldSubmitted: onFieldSubmitted,
            style: textStyle,
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Colors.grey[100],
              filled: true,
              hintStyle: hintStyle ?? Theme.of(context).textTheme.bodyText2,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: border ??
                  OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
              enabledBorder: enabledBorder,
              focusedBorder: focusedBorder,
              errorBorder: errorBorder,
            ),
          ),
        ],
      ),
    );
  }
}
