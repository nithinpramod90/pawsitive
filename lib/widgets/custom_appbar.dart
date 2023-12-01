import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/location_screen.dart';
import 'package:pawsitive/screens/provider/product_provider.dart';
import 'package:pawsitive/services/firebase_services.dart';
import 'package:pawsitive/services/search_service.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  // ignore: prefer_final_fields
  SearchService _search = SearchService();
  // ignore: prefer_final_fields
  FirebaseService _service = FirebaseService();

  static List<Products> products = [];
  String address = '';
  late DocumentSnapshot sellerDetails;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    try {
      QuerySnapshot snapshot = await _service.products.get();
      List<Products> tempProducts = [];

      for (var doc in snapshot.docs) {
        var product = Products(
          document: doc,
          title: doc['title'],
          description: doc['description'],
          category: doc['category'],
          breed: doc['breed'],
          age: doc['age'],
        );
        getSellerAddress(doc['selleruid']);
        tempProducts.add(product);
      }

      if (mounted) {
        setState(() {
          products = tempProducts;
        });
      }
    } catch (e) {
      // Handle the error or inform the user
    }
  }

  getSellerAddress(sellerId) {
    _service.getSellerData(sellerId).then((value) {
      setState(() {
        address = value['address'];
        sellerDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);
    return FutureBuilder<DocumentSnapshot>(
      future: _service.users.doc(_service.user!.uid).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Address not selected");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          //snapshot.hasdata
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          if (data['address'] == null) {
            if (data['state'] == null) {
              GeoPoint latlong = data['location'];
              _service.getAddress(latlong.latitude, latlong.longitude).then((adres) {
                return appBar(adres, context, provider, sellerDetails);
              });
            }
          } else {
            return appBar(data['address'], context, provider, sellerDetails);
          }
        }

        return appBar("Fetching Location..", context, provider, sellerDetails);
      },
    );
  }

  Widget appBar(address, context, provider, sellerDetails) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: InkWell(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LocationScreen(
                  locationChanging: true,
                ),
              ));
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.black,
                  size: 25,
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Text(
                    address ?? 'No location found',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.grey.shade300,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      readOnly: true,
                      onTap: () {
                        _search.search(context: context, productList: products, address: address, provider: provider, sellerDetails: sellerDetails);
                      },
                      decoration: InputDecoration(
                          prefixIcon: const ImageIcon(
                            AssetImage('assets/images/search_dog.png'),
                            color: Colors.black,
                            size: 1.0,
                          ),
                          labelText: 'Search',
                          labelStyle: const TextStyle(
                            fontSize: 12,
                          ),
                          contentPadding: const EdgeInsets.only(left: 10, right: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
