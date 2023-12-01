import 'package:flutter/material.dart';
import 'package:pawsitive/donation_item/cat_sort_list.dart';
import 'package:pawsitive/screens/provider/cat_provider.dart';
import 'package:provider/provider.dart';

class ProductByCategory extends StatelessWidget {
  static const String id = 'product-by-category';

  const ProductByCategory({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    var _catProvider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          _catProvider.selectedCategory.toString(),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: const SingleChildScrollView(child: CatList()),
    );
  }
}
