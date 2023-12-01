import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:galleryimage/galleryimage.dart';
import 'package:pawsitive/screens/form/user_reviw_screen.dart';
import 'package:pawsitive/screens/provider/cat_provider.dart';
import 'package:pawsitive/services/firebase_services.dart';
import 'package:pawsitive/widgets/imagepicker_widget.dart';
import 'package:provider/provider.dart';

class DonationForm extends StatefulWidget {
  static const id = 'donation-form';

  const DonationForm({super.key});

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final _formKey = GlobalKey<FormState>();
  late FirebaseService _service;
  late TextEditingController _breedcontroller;
  late TextEditingController _agecontroller;
  late TextEditingController _titlecontroller;
  late TextEditingController _descriptioncontroller;
  late TextEditingController _vaccinationcontroller;
  late TextEditingController _categorycontroller;

  @override
  void initState() {
    super.initState();
    _service = FirebaseService();
    _breedcontroller = TextEditingController(text: '');
    _agecontroller = TextEditingController(text: '');
    _titlecontroller = TextEditingController(text: '');
    _descriptioncontroller = TextEditingController(text: '');
    _vaccinationcontroller = TextEditingController(text: '');
    _categorycontroller = TextEditingController(text: '');

    Future.delayed(Duration.zero, () {
      final catProvider = Provider.of<CategoryProvider>(context, listen: false);
      _loadData(catProvider);
    });
  }

  void _loadData(CategoryProvider provider) {
    if (provider.dataToFirestore.isNotEmpty) {
      _breedcontroller.text = provider.dataToFirestore['breed'] ?? '';
      _agecontroller.text = provider.dataToFirestore['age'] ?? '';
      _titlecontroller.text = provider.dataToFirestore['title'] ?? '';
      _descriptioncontroller.text = provider.dataToFirestore['description'] ?? '';
      _vaccinationcontroller.text = provider.dataToFirestore['vaccination'] ?? '';
      _categorycontroller.text = provider.dataToFirestore['category'] ?? '';
    }
  }

  @override
  void dispose() {
    _breedcontroller.dispose();
    _agecontroller.dispose();
    _titlecontroller.dispose();
    _descriptioncontroller.dispose();
    _vaccinationcontroller.dispose();
    _categorycontroller.dispose();
    super.dispose();
  }

  validate(CategoryProvider provider) {
    if (_formKey.currentState!.validate()) {
      if (provider.urllist.isNotEmpty) {
        provider.dataToFirestore.addAll({
          'category': _categorycontroller.text,
          'subCat': provider.selectedSubCat,
          'breed': _breedcontroller.text,
          'age': _agecontroller.text,
          'title': _titlecontroller.text,
          'description': _descriptioncontroller.text,
          'vaccination': _vaccinationcontroller.text,
          'selleruid': _service.user!.uid,
          'images': provider.urllist,
          'favourites': []
        });
        Navigator.pushNamed(context, UserReviewScreen.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image not uploaded'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide all information'),
        ),
      );
    }
  }

  final List<String> _vacinationlist = [
    'Vaccinated',
    'Not Vaccinated',
    'Not Known'
  ];
  @override
  void didChangeDependencies() {
    var catprovider = Provider.of<CategoryProvider>(context);

    // Only set the text if the controller's text is empty.
    setState(() {
      _breedcontroller.text = _breedcontroller.text.isEmpty ? catprovider.dataToFirestore['breed'] ?? '' : _breedcontroller.text;
      _agecontroller.text = _agecontroller.text.isEmpty ? catprovider.dataToFirestore['age'] ?? '' : _agecontroller.text;
      _titlecontroller.text = _titlecontroller.text.isEmpty ? catprovider.dataToFirestore['title'] ?? '' : _titlecontroller.text;
      _descriptioncontroller.text = _descriptioncontroller.text.isEmpty ? catprovider.dataToFirestore['description'] ?? '' : _descriptioncontroller.text;
      _vaccinationcontroller.text = _vaccinationcontroller.text.isEmpty ? catprovider.dataToFirestore['vaccination'] ?? '' : _vaccinationcontroller.text;
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseService service = FirebaseService();
    // var _catprovider = Provider.of<CategoryProvider>(context);
    var catProvider = Provider.of<CategoryProvider>(context);
    Widget appBar(String? title, String fieldValue) {
      final nonNullableTitle = title ?? ' ';
      return AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
        title: Text(
          '$nonNullableTitle: $fieldValue',
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      );
    }

    Widget listview({required String fieldValue, required List<String> list, required TextEditingController textController}) {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            appBar(catProvider.selectedCategory ?? ' ', fieldValue),
            ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      textController.text = list[index];
                      Navigator.pop(context);
                    },
                    title: Text(list[index]),
                  );
                })
          ],
        ),
      );
    }

    // ignore: unused_element
    Widget brandlist() {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            appBar(catProvider.selectedCategory ?? 'Default Category', 'brands'),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: catProvider.doc['models'].length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                        setState(() {
                          _vaccinationcontroller.text = catProvider.doc['models'][index];
                        });
                        Navigator.pop(context);
                      },
                      title: Text(catProvider.doc['models'][index]),
                    );
                  }),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          'Add some details',
          style: TextStyle(color: Colors.black),
        ),
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Donation Registration Form',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // Explicitly cast your CollectionReference to the correct type.
                          var categoryCollection = service.categories.withConverter<Map<String, dynamic>>(
                            fromFirestore: (snapshot, _) => snapshot.data()!,
                            toFirestore: (value, _) => value,
                          );
                          return Dialog(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.5, // Set a fixed height (adjust as needed)
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                future: categoryCollection.get(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text('Something went wrong');
                                  }
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  return Material(
                                    type: MaterialType.transparency,
                                    child: ListView.builder(
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        var doc = snapshot.data!.docs[index].data();
                                        var catName = doc['catName'] as String? ?? 'Unnamed Category';
                                        var imageUrl = doc['image'] as String?; // Assuming 'image' is a URL

                                        return Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: ListTile(
                                            onTap: () {
                                              _categorycontroller.text = catName;
                                              Navigator.pop(context);
                                            },
                                            leading: imageUrl != null ? Image.network(imageUrl) : null,
                                            title: Text(catName),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _categorycontroller,
                        decoration: const InputDecoration(
                          labelText: 'Cattegory',
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide category details';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _titlecontroller,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      labelText: 'Tittle',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Provide a tittle';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _descriptioncontroller,
                    maxLength: 4000,
                    decoration: const InputDecoration(
                      counterText: 'Please provide details correctly.',
                      labelText: 'Description',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Provide a Description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return listview(
                              fieldValue: 'Vaccination',
                              list: _vacinationlist,
                              textController: _vaccinationcontroller,
                            );
                          });
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _vaccinationcontroller,
                        decoration: const InputDecoration(
                          labelText: 'Vaccination',
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide vaccination details';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _breedcontroller,
                    decoration: const InputDecoration(labelText: 'Breed'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please complete Required Field';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _agecontroller,
                    decoration: const InputDecoration(
                      labelText: 'Age*',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please complete Required Field';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: catProvider.urllist.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('No image selected'),
                          )
                        : GalleryImage(
                            imageUrls: catProvider.urllist,
                            numOfShowImages: catProvider.urllist.length.bitLength,
                          ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const ImagePickerWidget();
                          });
                    },
                    child: Neumorphic(
                      style: NeumorphicStyle(
                        border: NeumorphicBorder(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(catProvider.urllist.isNotEmpty ? 'Upload More Images' : 'Upload Images'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 40,
                child: NeumorphicButton(
                  style: NeumorphicStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    validate(catProvider);
                    print(catProvider.dataToFirestore);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
