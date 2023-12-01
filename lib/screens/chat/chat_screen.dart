// ignore_for_file: avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/chat/chat_card.dart';
import 'package:pawsitive/services/firebase_services.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseService service = FirebaseService();

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: const Text(
            'Chats',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25),
          ),
          bottom: const TabBar(
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              labelColor: Colors.white,
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Adoptions'),
                Tab(text: 'Donations')
              ]),
        ),
        body: TabBarView(
          children: [
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: service.messages.where('users', arrayContains: service.user?.uid).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      ),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Nothing to show here'),
                    );
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      return ChatCard(
                        data,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: service.messages.where('users', arrayContains: service.user?.uid).where('product.seller', isNotEqualTo: service.user!.uid).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      ),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Nothing to show here'),
                    );
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      return ChatCard(
                        data,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: service.messages.where('users', arrayContains: service.user?.uid).where('product.seller', isEqualTo: service.user!.uid).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      ),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Nothing to show here'),
                    );
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      return ChatCard(
                        data,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
