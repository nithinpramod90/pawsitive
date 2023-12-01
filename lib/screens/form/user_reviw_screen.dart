import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:pawsitive/screens/main_screen.dart';
import 'package:pawsitive/screens/provider/cat_provider.dart';
import 'package:pawsitive/services/firebase_services.dart';
import 'package:provider/provider.dart';

class UserReviewScreen extends StatefulWidget {
  const UserReviewScreen({super.key});
  static const String id = 'user-review-screen';

  @override
  State<UserReviewScreen> createState() => _UserReviewScreenState();
}

class _UserReviewScreenState extends State<UserReviewScreen> {
  final _formkey = GlobalKey<FormState>();
  bool _loading = false;
  final FirebaseService _service = FirebaseService();
  final _namecontroller = TextEditingController();
  final _countryCodecontroller = TextEditingController(text: '+91');
  final _phonecontroller = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _addresscontroller = TextEditingController();
  @override
  void initState() {
    super.initState();

    // Set up a listener on the phone controller
    _phonecontroller.addListener(() {
      final text = _phonecontroller.text;
      if (text.length > 12) {
        final newText = text.substring(3);
        _phonecontroller.value = _phonecontroller.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    });
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is disposed
    _phonecontroller.dispose();
    super.dispose();
  }

  Future<void> updateUser(CategoryProvider provider, Map<String, dynamic> data, BuildContext context) {
    return _service.users.doc(_service.user!.uid).update(data).then((value) {
      saveproductToDb(provider, context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $error'), // Use $error, not $e
        ),
      );
    });
  }

  Future<void> saveproductToDb(CategoryProvider provider, context) {
    return _service.products.add(provider.dataToFirestore).then(
      (value) {
        provider.clearData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('We have recieved your products and will be notified you once get approved'),
          ),
        );
        Navigator.pushReplacementNamed(context, MainScreen.id);
      },
    ).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update Data'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    showConfirmDialog() {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'confirm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text('Are you sure want to donate'),
                    const SizedBox(
                      height: 18,
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(provider.dataToFirestore['images'][0]),
                      ),
                      title: Text(
                        provider.dataToFirestore['title'],
                        maxLines: 1,
                      ),
                      subtitle: Text(provider.dataToFirestore['breed']),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        NeumorphicButton(
                          onPressed: () {
                            setState(() {
                              _loading = false;
                            });
                            Navigator.pop(context);
                          },
                          style: NeumorphicStyle(
                            border: NeumorphicBorder(color: Theme.of(context).primaryColor),
                            color: Colors.transparent,
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        NeumorphicButton(
                          style: NeumorphicStyle(color: Theme.of(context).primaryColor),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              _loading = true;
                            });
                            updateUser(
                                    provider,
                                    {
                                      'contactDetails': {
                                        'name': _namecontroller.text,
                                        'contactMobile': _phonecontroller.text,
                                        'contactEmail': _emailcontroller.text,
                                      }
                                    },
                                    context)
                                .then((value) {
                              setState(() {
                                _loading = false;
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (_loading)
                      Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ))
                  ],
                ),
              ),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Review your Details',
          style: TextStyle(color: Colors.black),
        ),
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: provider.getuserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text('No user details found'));
          } else {
            final userDetails = snapshot.data!.data() as Map<String, dynamic>? ?? {};

            // Set the text in controllers if the data is not null
            _namecontroller.text = userDetails['name'] ?? '';
            _phonecontroller.text = userDetails['mobile'] ?? '';
            _emailcontroller.text = userDetails['email'] ?? '';
            _addresscontroller.text = userDetails['address'] ?? '';

            return SingleChildScrollView(
              child: Form(
                key: _formkey,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/images/avatar.png'),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _namecontroller,
                              decoration: const InputDecoration(labelText: 'Your Name'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Your Name';
                                }
                                return null;
                              },
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text(
                        'Contact Details',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _countryCodecontroller,
                              readOnly: true,
                              decoration: const InputDecoration(labelText: 'Country', helperText: ''),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              maxLength: 10,
                              controller: _phonecontroller,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Mobile number',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Mobile Number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _emailcontroller,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          final bool isValid = EmailValidator.validate(_emailcontroller.text);
                          if (value == null || value.isEmpty) {
                            return 'Enter Email';
                          }
                          if (value.isNotEmpty && isValid == false) {
                            return 'Enter Valid Email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _addresscontroller,
                        decoration: const InputDecoration(labelText: 'Address'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please complete Required Field';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: NeumorphicButton(
                style: NeumorphicStyle(color: Theme.of(context).primaryColor),
                child: const Text(
                  'Confirm',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    showConfirmDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter Required Fields'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
