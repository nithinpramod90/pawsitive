import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/authentication/email_auth_screen.dart';

class PasswordResetScreen extends StatelessWidget {
  static const String id = 'password-reset-screen';

  const PasswordResetScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var emailcontroller = TextEditingController();
    final formkey = GlobalKey<FormState>();
    return Scaffold(
      body: Form(
        key: formkey,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock,
                color: Theme.of(context).primaryColor,
                size: 75,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Forgot\nPassword?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Enter your Email.\nWe will sent link to reset your password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 370,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: emailcontroller,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10),
                    labelText: 'Registered Email',
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  validator: (value) {
                    final bool isValid = EmailValidator.validate(emailcontroller.text);
                    if (value == null || value.isEmpty) {
                      return 'Enter Email';
                    }
                    if (value.isNotEmpty && isValid == false) {
                      return 'Enter Valid Email';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          if (formkey.currentState!.validate()) {
            FirebaseAuth.instance.sendPasswordResetEmail(email: emailcontroller.text).then((value) {
              Navigator.pushReplacementNamed(context, EmailAuthScreen.id);
            });
          }
        },
        child: const Text('Send'),
      ),
    );
  }
}
