// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:galleryimage/galleryimage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawsitive/screens/provider/cat_provider.dart';
import 'package:provider/provider.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? imagePath;
  bool _uploading = false;
  Future getImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          imagePath = File(pickedImage.path);
        });
      }
    } catch (e) {
      // Handle the error, perhaps show an alert to the user
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<CategoryProvider>(context);
    Future<String> uploadFile() async {
      File file = File(imagePath!.path);
      String imageName = 'productImage/${DateTime.now().microsecondsSinceEpoch}';
      String? downloadurl;
      try {
        await FirebaseStorage.instance.ref(imageName).putFile(file);
        downloadurl = await FirebaseStorage.instance.ref(imageName).getDownloadURL();
        setState(() {
          imagePath = null;
          provider.getImages(downloadurl);
        });
      } on FirebaseException {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('cancelled'),
          ),
        );
      }
      return downloadurl!;
    }

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            elevation: 1,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            title: const Text(
              'Upload Images',
              style: TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    if (imagePath != null)
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              imagePath = null;
                            });
                          },
                        ),
                      ),
                    SizedBox(
                      height: 120,
                      width: MediaQuery.of(context).size.width,
                      child: FittedBox(
                        child: imagePath == null
                            ? const Icon(
                                CupertinoIcons.photo_on_rectangle,
                                color: Colors.grey,
                              )
                            : Image.file(imagePath!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                if (provider.urllist.isNotEmpty) //the problem with updation
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: GalleryImage(
                      imageUrls: provider.urllist,
                      numOfShowImages: provider.urllist.length.bitLength, //grid error
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (imagePath != null)
                  Row(
                    children: [
                      Expanded(
                        child: NeumorphicButton(
                          style: const NeumorphicStyle(color: Colors.green),
                          onPressed: () {
                            setState(() {
                              _uploading = true;
                              uploadFile().then((url) {
                                setState(() {
                                  _uploading = false;
                                });
                              });
                            });
                          },
                          child: const Text(
                            'Save',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: NeumorphicButton(
                          style: const NeumorphicStyle(color: Colors.red),
                          onPressed: () {
                            setState(() {
                              imagePath = null;
                            });
                          },
                          child: const Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                        child: NeumorphicButton(
                      onPressed: getImage,
                      style: NeumorphicStyle(color: Theme.of(context).primaryColor),
                      child: const Text(
                        'Upload Image',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_uploading)
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
