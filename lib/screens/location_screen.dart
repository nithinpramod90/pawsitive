import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:dialogs/dialogs/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:pawsitive/screens/home_screen.dart';
import 'package:pawsitive/screens/main_screen.dart';
import 'package:pawsitive/services/firebase_services.dart';

class LocationScreen extends StatefulWidget {
  static const String id = 'location-screen';
  final bool? locationChanging;

  // ignore: prefer_const_constructors_in_immutables
  LocationScreen({super.key, this.locationChanging});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.locationChanging == null) {
        _service.users.doc(_service.user!.uid).get().then((DocumentSnapshot document) async {
          if (document.exists) {
            if (document['address'] != null) {
              if (mounted) {
                setState(() {
                  _loading = true;
                });
              }
              await Navigator.pushReplacementNamed(context, MainScreen.id);
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, HomeScreen.id);
            } else {
              setState(() {
                _loading = false;
              });
            }
          }
        });
        // ignore: use_build_context_synchronously
      } else {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  final FirebaseService _service = FirebaseService();
  bool _loading = true;
  loc.Location location = loc.Location();

  bool? _serviceEnabled;
  loc.PermissionStatus? _permissionGranted;
  loc.LocationData? _locationData;
  List<Placemark>? placemarks;

  String countryValue = "";
  String? stateValue = "";
  String? cityValue = "";
  String? address = "";
  String? manualAddress;

  Future<loc.LocationData?> getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {}
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {}
    }

    _locationData = await location.getLocation();

    if (_locationData != null) {
      final latitude = _locationData!.latitude;
      final longitude = _locationData!.longitude;
      placemarks = await placemarkFromCoordinates(latitude!, longitude!);
    }
    return _locationData;
  }

  @override
  Widget build(BuildContext context) {
    ProgressDialog progressDialog = ProgressDialog(
      context: context,
      backgroundColor: Theme.of(context).primaryColor,
      textColor: Colors.black,
      loadingText: 'Fetching Location..',
      progressIndicatorColor: Colors.black,
    );

    void showBottomScreen() {
      getLocation();
      progressDialog.dismiss();

      showModalBottomSheet(
          isScrollControlled: true,
          enableDrag: true,
          context: context,
          builder: (context) {
            return Column(
              children: [
                const SizedBox(
                  height: 26,
                ),
                AppBar(
                  automaticallyImplyLeading: false,
                  iconTheme: const IconThemeData(color: Colors.black),
                  elevation: 1,
                  backgroundColor: Colors.white,
                  title: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.clear),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'Location',
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                ListTile(
                  onTap: () {
                    _loading = false;
                    getLocation().then((value) {
                      if (value != null) {
                        _service.updateUser({
                          'location': GeoPoint(value.latitude!.toDouble(), value.longitude!.toDouble()),
                          'address': '${placemarks!.first.subLocality}, ${placemarks!.first.locality}, ${placemarks!.first.postalCode}, ${placemarks!.first.administrativeArea}, ${placemarks!.first.country}',
                        }, context).then((value) async {
                          _loading = false;
                          // Navigator.pushNamed(context, HomeScreen.id);
                          Navigator.pushNamed(context, MainScreen.id);
                        });
                      }
                    });
                  },
                  horizontalTitleGap: 0.0,
                  leading: const Icon(Icons.location_on_outlined, color: Colors.blue),
                  title: const Text('Use current location', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    _locationData == null
                        ? 'Fetching Location...'
                        : (placemarks != null && placemarks!.isNotEmpty)
                            ? "${placemarks![0].name}, ${placemarks![0].locality}, ${placemarks![0].country}"
                            : "Unknown Address",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey.shade300,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 4, top: 4),
                    child: Text(
                      'CHOOSE CITY',
                      style: TextStyle(
                        color: Colors.blueGrey.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: CSCPicker(
                      layout: Layout.vertical,
                      dropdownDecoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.grey.shade300,
                        borderRadius: const BorderRadius.all(Radius.circular(3)),
                      ),
                      onCountryChanged: (value) {
                        setState(() {
                          countryValue = value;
                        });
                      },
                      onStateChanged: (value) {
                        setState(() {
                          stateValue = value;
                        });
                      },
                      onCityChanged: (value) {
                        setState(() {
                          cityValue = value;
                          manualAddress = '$cityValue, $stateValue, ${countryValue.substring(8)}';
                        });
                        if (value != null) {
                          _service.updateUser({
                            'address': manualAddress,
                            'state': stateValue,
                            'city': cityValue,
                            'country': countryValue,
                          }, context);
                        }
                      }),
                ),
              ],
            );
          });
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Image.asset('assets/images/location.png'),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "I'm Curious \n Where are you right Now",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'To provide you the best experience let us know\n your location',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(
              height: 15,
            ),
            _loading
                ? const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 8,
                      ),
                      Text('Finding Location...')
                    ],
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: _loading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                                      ),
                                      icon: const Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.white,
                                      ),
                                      label: const Padding(
                                        padding: EdgeInsets.only(top: 15, bottom: 15),
                                        child: Text(
                                          'Around Me',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          progressDialog.show();
                                        });
                                        _loading = true;
                                        getLocation().then((value) {
                                          if (value != null) {
                                            _service.updateUser({
                                              'location': GeoPoint(value.latitude!.toDouble(), value.longitude!.toDouble()),
                                              'address': '${placemarks!.first.subLocality}, ${placemarks!.first.locality}, ${placemarks!.first.postalCode}, ${placemarks!.first.administrativeArea}, ${placemarks!.first.country}',
                                            }, context).then((value) async {
                                              _loading = false;
                                              await Navigator.pushNamed(context, MainScreen.id);

                                              // ignore: use_build_context_synchronously
                                              await Navigator.pushNamed(context, HomeScreen.id);
                                              progressDialog.dismiss();
                                            });
                                          }
                                        });
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          progressDialog.show();
                          showBottomScreen();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(width: 2)),
                            ),
                            child: const Text(
                              "Other Location's",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ));
  }
}
