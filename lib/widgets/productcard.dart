import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/product_details_screen.dart';
import 'package:pawsitive/screens/provider/product_provider.dart';
import 'package:pawsitive/services/firebase_services.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.data,
  });

  final QueryDocumentSnapshot<Object?> data;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final FirebaseService _service = FirebaseService();
  String address = '';
  late DocumentSnapshot sellerDetails;
  List fav = [];
  bool _isLiked = false;

  @override
  void initState() {
    getUserData();
    getFavourites();
    super.initState();
  }

  getUserData() {
    _service.getSellerData(widget.data['selleruid']).then((value) {
      if (mounted) {
        setState(() {
          address = value['address'];
          sellerDetails = value;
        });
      }
    });
  }

  getFavourites() {
    _service.products.doc(widget.data.id).get().then((value) {
      if (mounted) {
        setState(() {
          fav = value['favourites'];
        });
      }

      if (fav.contains(_service.user!.uid)) {
        if (mounted) {
          setState(() {
            _isLiked = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLiked = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);

    return InkWell(
      onTap: () {
        provider.getProductDetails(widget.data);
        provider.getSellerDetails(sellerDetails);
        Navigator.pushNamed(context, ProductDetails.id);
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.8),
            ),
            borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: Image.network(widget.data['images'][0]),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.data['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Age: ${widget.data['age']}',
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                      ),
                      Flexible(
                        child: Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                      _service.updateFavourite(_isLiked, widget.data.id);
                    },
                    icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                    color: _isLiked ? Colors.red : Colors.black,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
