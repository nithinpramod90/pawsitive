// ignore_for_file: sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/product_details_screen.dart';
import 'package:pawsitive/screens/product_list.dart';
import 'package:search_page/search_page.dart';

class Products {
  final String title, description, category, breed, age;

  final DocumentSnapshot document;
  const Products({required this.title, required this.description, required this.category, required this.breed, required this.age, required this.document});
}

class SearchService {
  search({required BuildContext context, required List<Products> productList, address, provider, sellerDetails}) {
    // Check if the productList is not empty
    if (productList.isEmpty) {
      // Handle the case where the list is empty, for example by showing a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Empty List'),
            content: const Text('No products to search.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
            ],
          );
        },
      );
    } else {
      // The list is not empty, proceed with showing the search page
      showSearch(
        context: context,
        delegate: SearchPage<Products>(
            // ignore: avoid_print
            onQueryUpdate: (s) => print(s), // You should replace this with an actual function if necessary
            items: productList,
            searchLabel: 'Adopt',
            suggestion: const SingleChildScrollView(child: ProductList()),
            failure: const Center(
              child: Text('No Donations found :('),
            ),
            filter: (product) => [
                  product.title,
                  product.description,
                  product.breed,
                ],
            builder: (product) {
              return InkWell(
                onTap: () {
                  provider.getProductDetails(product.document);
                  provider.getSellerDetails(sellerDetails);
                  Navigator.pushNamed(context, ProductDetails.id);
                },
                child: Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 120,
                            child: Image.network(product.document['images'][0]),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Breed : ${product.breed}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.black,
                                      ),
                                      Flexible(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width - 148,
                                          child: Text(
                                            address,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      );
    }
  }
}
