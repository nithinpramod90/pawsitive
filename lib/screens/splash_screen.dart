import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/location_screen.dart';
import 'package:pawsitive/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String id = 'splash-screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(
        const Duration(
          seconds: 3,
        ), () {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          Navigator.pushReplacementNamed(context, LoginScreen.id);
        } else {
          Navigator.pushReplacementNamed(context, LocationScreen.id);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const colorizeColors = [
      Colors.white,
      Colors.grey,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 30.0,
      fontFamily: 'Lato',
    );
    return Scaffold(
      backgroundColor: const Color(0xFFAAAAC2),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/pawsitive.png'),
            const SizedBox(
              height: 10,
            ),
            AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Donate and Adopt',
                  textStyle: colorizeTextStyle,
                  colors: colorizeColors,
                ),
              ],
              isRepeatingAnimation: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
