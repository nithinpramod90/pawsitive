import 'package:flutter/material.dart';
import 'package:pawsitive/screens/product_list.dart';

import 'package:pawsitive/widgets/banner_widget.dart';
import 'package:pawsitive/widgets/custom_appbar.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home-screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const PreferredSize(preferredSize: Size.fromHeight(100), child: SafeArea(child: CustomAppBar())),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Column(
                  children: [
                    BannerWidget(),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const ProductList(),
          ],
        ),
      ),
    );
  }
}
