// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/provider/cat_provider.dart';
import 'package:pawsitive/services/firebase_services.dart';
import 'package:pawsitive/widgets/productcard.dart';
import 'package:provider/provider.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  String address = '';

  _ProductListState();

  @override
  Widget build(BuildContext context) {
    FirebaseService service = FirebaseService();
    var catProvider = Provider.of<CategoryProvider>(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: FutureBuilder<QuerySnapshot>(
          future: service.products
              .where(
                'category', /*isEqualTo: _catProvider.selectedCategory*/
              )
              .get(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.only(left: 140, right: 140),
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                  backgroundColor: Colors.grey.shade100,
                ),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const Center(
                  child: Text(
                    'Nothing to show in this category',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 6,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 2 / 2.4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: snapshot.data!.size,
                  itemBuilder: (BuildContext context, int i) {
                    final data = snapshot.data!.docs[i];

                    return ProductCard(
                      data: data,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
