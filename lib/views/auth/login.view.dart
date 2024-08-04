import 'package:flutter/material.dart';
import 'package:parkme/services/auth.service.dart';
import 'package:parkme/utils/index.dart';
import 'package:parkme/views/auth/forget.password.view.dart';
import 'package:parkme/views/auth/signup.view.dart';
import 'package:parkme/views/home/home.view.dart';
import 'package:parkme/widgets/custom.filled.button.dart';
import 'package:parkme/widgets/custom.input.field.dart';
import 'package:parkme/widgets/custom.small.title.dart';
import 'package:parkme/widgets/custom.title.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _key = GlobalKey<FormState>();
  final _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        reverse: true,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: _key,
            child: Column(
              children: [
                const SizedBox(
                  height: 120,
                ),
                const CustomTitle(title: "Sign In"),
                const CustomSmallTitle(subtitle: "Log into your account"),
                const SizedBox(
                  height: 32,
                ),
                CustomInputField(
                    label: "Email",
                    hint: "example@example.com",
                    validator: (String? value) {
                      if (value != null) {
                        if (value.isEmpty) return "Please enter email";
                      }
                      return null;
                    },
                    controller: emailController),
                CustomInputField(
                  label: "Password",
                  hint: "*******",
                  controller: passwordController,
                  validator: (String? value) {
                    if (value != null) {
                      if (value.isEmpty) return "Please enter password";
                    }
                    return null;
                  },
                  isPassword: true,
                ),
                const SizedBox(
                  height: 16,
                ),
                Center(
                  child: TextButton(
                      onPressed: () {
                        context.navigator(context, const ForgetPasswordView());
                      },
                      child: const Text('Forget Password')),
                ),
                const SizedBox(
                  height: 16,
                ),
                CustomButton(
                    text: "Sign In",
                    onPressed: () async {
                      if (_key.currentState!.validate()) {
                        _authService
                            .signInWithEmailAndPassword(
                                emailController.text, passwordController.text)
                            .then((value) {
                          if (value != null) {
                            context.navigator(context, const HomeView());
                          } else {
                            context.showSnackBar(
                                "Signin failed, please try again");
                          }
                        }).catchError((error) {
                          context
                              .showSnackBar("Signin failed, please try again");
                        });
                      }
                    }),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        context.navigator(context, const SignupView());
                      },
                      child: const Text("Sign Up"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
