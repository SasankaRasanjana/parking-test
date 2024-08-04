import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/widgets/custom.filled.button.dart';
import 'package:parkme/widgets/custom.input.field.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      loading = true;
    });
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send password reset email: $e'),
        ),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInputField(
                  label: 'Email',
                  hint: 'example@gmail.com',
                  validator: (String? value) {
                    if (value != null) {
                      if (value.isEmpty) return "Please enter email";
                    }
                    return null;
                  },
                  controller: emailController),
              const SizedBox(
                height: 32,
              ),
              CustomButton(
                text: 'Send Password Reset Email',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _sendPasswordResetEmail();
                  }
                },
                loading: loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
