import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/authentication/email_verification_screen.dart';

class EmailAuthentication {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<DocumentSnapshot> getAdminCredential({email, password, isLog, context}) async {
    DocumentSnapshot result = await users.doc(email).get();
    if (isLog) {
      emailLogin(email, password, context);
    } else {
      if (result.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email already exists'),
          ),
        );
      } else {
        emailRegister(email, password, context);
      }
    }
    return result;
  }

  emailLogin(email, password, context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ignore: unnecessary_null_comparison
      if (userCredential.user!.uid != null) {
        Navigator.pushReplacementNamed(context, EmailVerificationScreen.id);
      } else {}
    } on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Criteria'),
        ),
      );
    }
  }

  emailRegister(email, password, context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user?.uid != null) {
        return users.doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'mobile': null,
          'email': userCredential.user!.email,
          'name': null,
          'address': null,
        }).then((value) async {
          await userCredential.user!.sendEmailVerification().then((value) {
            Navigator.pushReplacementNamed(context, EmailVerificationScreen.id);
          });
        }).catchError((onError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add user'),
            ),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weak password'),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('user already exist'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error occured'),
        ),
      );
    }
  }
}
