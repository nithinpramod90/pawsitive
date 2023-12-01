import 'package:dialogs/dialogs/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/services/phoneauth_serviece.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});
  static const String id = 'phone_auth';

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  bool validate = false;
  var countrycontroller = TextEditingController(text: '+91');
  var phonenumbercontroller = TextEditingController();

  final PhoneAuthServiece _service = PhoneAuthServiece();

  @override
  Widget build(BuildContext context) {
    ProgressDialog progressDialog = ProgressDialog(
      context: context,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      textColor: Colors.black,
      loadingText: 'Please wait',
      progressIndicatorColor: Theme.of(context).primaryColor,
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 40,
            ),
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Enter your Phone Number',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'We will send conformation code to your phone.',
              style: TextStyle(color: Colors.grey),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: countrycontroller,
                    enabled: false,
                    decoration: const InputDecoration(counterText: '0', labelText: 'Country'),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    onChanged: (value) {
                      if (value.length == 10) {
                        setState(() {
                          validate = true;
                        });
                      }
                      if (value.length < 10) {
                        setState(() {
                          validate = false;
                        });
                      }
                    },
                    autofocus: true,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    controller: phonenumbercontroller,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your Phone Number',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: AbsorbPointer(
            absorbing: validate ? false : true,
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: validate ? MaterialStateProperty.all(const Color(0xFF846A85)) : MaterialStateProperty.all(Colors.grey),
                ),
                onPressed: () {
                  progressDialog.show();
                  String number = '${countrycontroller.text}${phonenumbercontroller.text}';

                  _service.verifyPhoneNumber(context, number);
                },
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Next',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
