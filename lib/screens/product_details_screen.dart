// ignore_for_file: no_leading_underscores_for_local_identifiers, sized_box_for_whitespace

import 'dart:async';

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart' as launcher;
import 'package:pawsitive/screens/chat/chat_conversation_screen.dart';
import 'package:pawsitive/screens/provider/product_provider.dart';
import 'package:pawsitive/services/firebase_services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetails extends StatefulWidget {
  static const String id = 'product-details-screen';
  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  // ignore: unused_field
  late GoogleMapController _controller;
  final FirebaseService _service = FirebaseService();

  bool _loading = true;
  int _index = 0;
  List fav = [];
  bool _isLiked = false;
  @override
  void initState() {
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  _mapLauncher(location) async {
    final availableMaps = await launcher.MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
      coords: launcher.Coords(location.latitude, location.longitude),
      title: "",
    );
  }

  createChatRoom(ProductProvider _provider) {
    Map<String, dynamic> product = {
      'productId': _provider.productData.id,
      'productImage': _provider.productData['images'][0],
      'title': _provider.productData['title'],
      'seller': _provider.productData['selleruid']
    };
    List<String> users = [
      _provider.sellerDetails['uid'],
      _service.user!.uid,
    ];
    String chatRoomId = '${_provider.sellerDetails['uid']}.${_service.user!.uid}.${_provider.productData.id}';
    Map<String, dynamic> chatData = {
      'users': users,
      'chatRoomId': chatRoomId,
      'read': false,
      'product': product,
      'lastChatTime': DateTime.now().microsecondsSinceEpoch
    };
    _service.createChatRoom(chatData: chatData);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ChatConversations(
                  chatRoomId: chatRoomId,
                )));
  }

  @override
  void didChangeDependencies() {
    var _productProvider = Provider.of<ProductProvider>(context);

    getFavourites(_productProvider);
    super.didChangeDependencies();
  }

  getFavourites(ProductProvider _productprovider) {
    _service.products.doc(_productprovider.productData.id).get().then((value) {
      setState(() {
        fav = value['favourites'];
      });
      if (fav.contains(_service.user!.uid)) {
        setState(() {
          _isLiked = true;
        });
      } else {
        setState(() {
          _isLiked = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _productProvider = Provider.of<ProductProvider>(context);
    var data = _productProvider.productData;
    GeoPoint _location = _productProvider.sellerDetails['location'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isLiked = !_isLiked;
              });
              _service.updateFavourite(_isLiked, data.id);
            },
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
            color: _isLiked ? Colors.red : Colors.black,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  color: Colors.white,
                  child: _loading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text('Loading')
                            ],
                          ),
                        )
                      : Center(
                          child: ClipRect(
                          child: PhotoView(
                            backgroundDecoration: BoxDecoration(color: Colors.grey.shade300),
                            imageProvider: NetworkImage(data['images'][_index]),
                            minScale: PhotoViewComputedScale.contained * 1.0,
                            maxScale: PhotoViewComputedScale.contained * 1.0,
                            // Add other properties accordingly
                          ),
                        )),
                ),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data['images'].length,
                    itemBuilder: (BuildContext context, int i) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _index = i;
                          });
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Theme.of(context).primaryColor),
                          ),
                          child: Image.network(data['images'][i]),
                        ),
                      );
                    },
                  ),
                ),
                _loading
                    ? Container()
                    // ignore: avoid_unnecessary_containers
                    : Container(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    data['title'].toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Age: ${(data['age'])}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                color: Colors.grey.shade300,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.vaccines_outlined,
                                                size: 15,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                data['vaccination'],
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        color: Colors.grey,
                                        thickness: 1.5,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12, right: 12),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.animation,
                                                  size: 15,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  data['breed'],
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 30,
                                            ),
                                            Expanded(
                                              // ignore: avoid_unnecessary_containers
                                              child: Container(
                                                child: AbsorbPointer(
                                                  absorbing: true,
                                                  child: TextButton.icon(
                                                    onPressed: () {},
                                                    style: const ButtonStyle(alignment: Alignment.center),
                                                    icon: const Icon(
                                                      Icons.location_on_outlined,
                                                      size: 15,
                                                      color: Colors.black,
                                                    ),
                                                    label: Flexible(
                                                      child: Text(
                                                        // ignore: unnecessary_null_comparison
                                                        _productProvider.sellerDetails == null ? '' : _productProvider.sellerDetails['address'],
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.black,
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: Colors.grey.shade300,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Description',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(data['description'])
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1.5,
                              ),
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 35,
                                    backgroundImage: AssetImage('assets/images/avatar.png'),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: const Text(
                                        'Posted by',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      subtitle: Text(
                                        _productProvider.sellerDetails['contactDetails']?['name'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1.5,
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Donation Posted At',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                color: Colors.grey,
                                height: 200,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(_location.latitude, _location.longitude),
                                          zoom: 15,
                                        ),
                                        mapType: MapType.normal,
                                        onMapCreated: (GoogleMapController controller) {
                                          setState(() {
                                            _controller = controller;
                                          });
                                        },
                                      ),
                                    ),
                                    const Center(
                                      child: Icon(
                                        Icons.location_on,
                                        size: 35,
                                      ),
                                    ),
                                    const Center(
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.black12,
                                      ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: Material(
                                        elevation: 4,
                                        shape: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            _mapLauncher(_location);
                                          },
                                          icon: const Icon(Icons.route),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Donation Id : ${data['selleruid']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(
                                height: 60,
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              _productProvider.productData['selleruid'] == _service.user!.uid
                  ? Expanded(
                      child: NeumorphicButton(
                        onPressed: () {},
                        style: NeumorphicStyle(color: Theme.of(context).primaryColor),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Edit Donation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: NeumorphicButton(
                        onPressed: () {
                          createChatRoom(_productProvider);
                        },
                        style: NeumorphicStyle(color: Theme.of(context).primaryColor),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Chat',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
