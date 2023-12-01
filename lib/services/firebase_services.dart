// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pawsitive/screens/home_screen.dart';

class FirebaseService {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference categories = FirebaseFirestore.instance.collection('categories');
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  CollectionReference messages = FirebaseFirestore.instance.collection('messages');

  User? user = FirebaseAuth.instance.currentUser;

  Future<void> updateUser(Map<String, dynamic> data, BuildContext context) async {
    print("Attempting to update user data: $data");

    if (user == null) {
      print("User is null. Cannot update data.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User is not authenticated. Cannot update data.'),
        ),
      );
      return;
    }

    try {
      await users
          .doc(user!.uid)
          .update(
            data,
          )
          .then((value) {
        Navigator.pushNamed(context, HomeScreen.id);
      });
    } catch (error) {
      print("Error updating/creating user data: $error");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update/create data. Error: $error'),
        ),
      );
    }
  }

  Future<String?> getAddress(lat, long) async {
    final latitude = lat;
    final longitude = long;
    final placemarks = await placemarkFromCoordinates(latitude!, longitude!);
    return placemarks.toString();
  }

  Future<DocumentSnapshot> getUserData() async {
    DocumentSnapshot doc = await users.doc(user!.uid).get();
    return doc;
  }

  Future<DocumentSnapshot> getSellerData(id) async {
    DocumentSnapshot doc = await users.doc(id).get();
    return doc;
  }

  Future<DocumentSnapshot> getProductDetails(id) async {
    DocumentSnapshot doc = await products.doc(id).get();
    return doc;
  }

  createChatRoom({chatData}) {
    messages.doc(chatData['chatRoomId']).set(chatData).catchError((e) {
      print(e.toString());
    });
  }

  createChat(String chatRoomId, message) {
    // ignore: body_might_complete_normally_catch_error
    messages.doc(chatRoomId).collection('chats').add(message).catchError((e) {});
    messages.doc(chatRoomId).update({
      'lastChat': message['message'],
      'lastChatTime': message['time'],
      'read': false
    });
  }

  getchat(chatRoomId) async {
    return messages.doc(chatRoomId).collection('chats').orderBy('time').snapshots();
  }

  deleteChat(chatRoomId) async {
    return messages.doc(chatRoomId).delete();
  }

  updateFavourite(isLiked, productId) {
    if (isLiked) {
      return products.doc(productId).update({
        'favourites': FieldValue.arrayUnion([
          user!.uid
        ])
      });
    } else {
      return products.doc(productId).update({
        'favourites': FieldValue.arrayRemove([
          user!.uid
        ])
      });
    }
  }
}
