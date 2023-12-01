import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/authentication/otp_screen.dart';
import 'package:pawsitive/screens/location_screen.dart';

class PhoneAuthServiece {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  Future<void> addUser(context, uid) async {
    User? user = FirebaseAuth.instance.currentUser;

    final CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      QuerySnapshot result = await users.where('uid', isEqualTo: uid).get();
      List<DocumentSnapshot> document = result.docs;

      if (document.isNotEmpty) {
        Navigator.pushReplacementNamed(context, LocationScreen.id);
      } else {
        await users.doc(user?.uid).set({
          'uid': user?.uid,
          'mobile': user?.phoneNumber,
          'email': user?.email,
          'name': null,
          'address': null,
        });
        Navigator.pushReplacementNamed(context, LocationScreen.id);
      }
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> verifyPhoneNumber(BuildContext context, number) async {
    verificationCompleted(PhoneAuthCredential credential) async {
      await auth.signInWithCredential(credential);
    }

    verificationFailed(FirebaseAuthException e) {
      if (e.code == 'invalid-phone-number') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Criteria'),
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Criteria'),
        ),
      );
    }

    codeSent(verId, int? resendToken) async {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OTPScreen(
                    number: number,
                    verId: verId,
                  )));
    }

    try {
      auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error${e.toString()}'),
        ),
      );
    }
  }
}
