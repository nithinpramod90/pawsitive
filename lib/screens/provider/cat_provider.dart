import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pawsitive/services/firebase_services.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseService _service = FirebaseService();
  late DocumentSnapshot doc;
  DocumentSnapshot? userDetails;
  String? selectedCategory;
  String? selectedSubCat;
  List<String> urllist = [];
  Map<String, dynamic> dataToFirestore = {};
  //
  getCategory(selectedCat) {
    selectedCategory = selectedCat;
    notifyListeners();
  }

  getSubCategory(selectedCat) {
    selectedSubCat = selectedSubCat;
    notifyListeners();
  }

  //
  getImages(url) {
    urllist.add(url);
    notifyListeners();
  }
//

  getData(data) {
    dataToFirestore = data;
    notifyListeners();
  }

  Future<DocumentSnapshot> getuserDetails() async {
    // Assuming getUserData returns a Future<DocumentSnapshot>
    DocumentSnapshot userDetails = await _service.getUserData();
    // Do something with userDetails if needed
    notifyListeners();
    return userDetails; // Make sure to return the DocumentSnapshot
  }

  clearData() {
    urllist = [];
    dataToFirestore = {};
    notifyListeners();
  }
}
