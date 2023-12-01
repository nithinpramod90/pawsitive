// ignore_for_file: avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/services/firebase_services.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseService service = FirebaseService();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: FutureBuilder<QuerySnapshot>(
          future: service.categories.get(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Container();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }

            return Container(
                child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                // ignore: unused_local_variable
                var doc = snapshot.data!.docs[index];
                return null;
              },
            ));
          },
        ),
      ),
    );
  }
}
