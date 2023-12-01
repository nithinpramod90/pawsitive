import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/services/firebase_services.dart';
import 'package:pawsitive/widgets/productcard.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  final FirebaseService _service = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: const Text(
            'My Donations',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 20),
            child: TabBar(indicatorColor: Colors.grey.shade300, indicatorWeight: 6, tabs: const [
              Tab(
                child: Text(
                  'Donations',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Favourites',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ]),
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: FutureBuilder<QuerySnapshot>(
                  future: _service.products.where('selleruid', isEqualTo: _service.user!.uid).get(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('Nothing to show here'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 140, right: 140),
                        child: Center(
                          child: LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                            backgroundColor: Colors.grey.shade100,
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 2 / 2.3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: snapshot.data!.size,
                            itemBuilder: (BuildContext context, int i) {
                              final data = snapshot.data!.docs[i];
                              return ProductCard(data: data);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _service.products.where('favourites', arrayContains: _service.user!.uid).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('Nothing to show here'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 140, right: 140),
                        child: Center(
                          child: LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                            backgroundColor: Colors.grey.shade100,
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 2 / 2.3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: snapshot.data!.size,
                            itemBuilder: (BuildContext context, int i) {
                              final data = snapshot.data!.docs[i];
                              return ProductCard(data: data);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
