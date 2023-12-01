import 'package:flutter/material.dart';
import 'package:pawsitive/widgets/auth_ui.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  static const String id = 'login-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(168, 164, 100, 165),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  Image.asset('assets/images/pawsitive.png')
                ],
              ),
            ),
          ),
          const Expanded(
            child: AuthUi(),
          ),
        ],
      ),
    );
  }
}
