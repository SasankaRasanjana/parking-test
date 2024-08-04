import 'package:flutter/material.dart';
import 'package:parkme/models/app.user.model.dart';
import 'package:parkme/services/app.user.service.dart';
import 'package:parkme/services/auth.service.dart';
import 'package:parkme/utils/index.dart';
import 'package:parkme/views/auth/login.view.dart';
import 'package:parkme/views/home/home.view.dart';
import 'package:parkme/widgets/custom.filled.button.dart';
import 'package:parkme/widgets/custom.input.field.dart';
import 'package:parkme/widgets/custom.small.title.dart';
import 'package:parkme/widgets/custom.title.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _key = GlobalKey<FormState>();
  final _authService = AuthService();
  final _appUserService = AppUserService();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        reverse: true,
        child: Form(
          key: _key,
          child: Column(
            children: [
              const SizedBox(
                height: 120,
              ),
              const CustomTitle(title: "Create account"),
              const CustomSmallTitle(subtitle: "Create your own account"),
              const SizedBox(
                height: 32,
              ),
              CustomInputField(
                  label: "Username",
                  hint: "Ex: James Wann",
                  validator: (String? value) {
                    if (value != null) {
                      if (value.isEmpty) return "Please enter an username";
                    }
                    return null;
                  },
                  controller: usernameController),
              const SizedBox(
                height: 8,
              ),
              CustomInputField(
                label: "Email",
                hint: "example@example.com",
                controller: emailController,
                validator: (String? value) {
                  if (value != null) {
                    if (value.isEmpty) return "Please enter email";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 8,
              ),
              CustomInputField(
                label: "Password",
                hint: "**********",
                controller: passwordController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password";
                  }
                  String pattern =
                      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
                  RegExp regex = RegExp(pattern);
                  if (!regex.hasMatch(value)) {
                    return "Password must be at least 8 characters long,\ninclude an upper case letter, lower case letter,\nnumber, and special character.";
                  }
                  return null;
                },
                isPassword: true,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomButton(
                loading: loading,
                text: "Sign up",
                onPressed: () {
                  if (_key.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });
                    _authService
                        .registerWithEmailAndPassword(
                            emailController.text, passwordController.text)
                        .then((value) async {
                      AppUser user = AppUser(
                          email: emailController.text,
                          username: usernameController.text,
                          role: "User");
                      await _appUserService.setUser(user).then((value) =>
                          context.navigator(context, const HomeView(),
                              shouldBack: false));
                    }).catchError((error) {
                      context.showSnackBar("Signup failed, please try again");
                    });
                    setState(() {
                      loading = false;
                    });
                  }
                },
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                      onPressed: () {
                        context.navigator(context, const LoginView());
                      },
                      child: const Text("Sign in"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
