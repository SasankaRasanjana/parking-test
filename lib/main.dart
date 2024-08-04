import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parkme/providers/home.provider.dart';
import 'package:parkme/providers/parking.provider.dart';
import 'package:parkme/views/home/home.view.dart';
import 'package:parkme/views/splash.screen.view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Stripe.publishableKey =
  //     'pk_test_51Nm6kJCY3f1OD3gTSHubi5R4tZ5u8IvZOSrAAsQ7LxiJjbksjUswukAc23NRPiTIMZeW3knxkrzTNihIzk3l2hPL00XjpBa5Vi';
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => HomeProvider()),
          ChangeNotifierProvider(create: (context) => ParkingProvider()),
        ],
        child: MaterialApp(
          theme: ThemeData(
            fontFamily: "Rubik",
            scaffoldBackgroundColor: Colors.grey[200],
          ),
          home: FirebaseAuth.instance.currentUser != null
              ? const HomeView()
              : const SplashScreenView(),
        ));
  }
}
