import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/authentication/phoneauth_screen.dart';
import 'package:pawsitive/services/phoneauth_serviece.dart';

class OTPScreen extends StatefulWidget {
  final String number, verId;
  const OTPScreen({super.key, required this.number, required this.verId});
  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool _loading = false;
  late String error = '';
  final PhoneAuthServiece _services = PhoneAuthServiece();
  final _text1 = TextEditingController();
  final _text2 = TextEditingController();
  final _text3 = TextEditingController();
  final _text4 = TextEditingController();
  final _text5 = TextEditingController();
  final _text6 = TextEditingController();
  Future<void> phoneCredential(
    BuildContext context,
    String otp,
  ) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verId, smsCode: otp);
      final User? user = (await auth.signInWithCredential(credential)).user;
      if (user != null) {
        // ignore: use_build_context_synchronously
        _services.addUser(context, user.uid);
      } else {
        if (mounted) {
          setState(() {
            error = 'Login Failed';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Invalid OTP';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 20, left: 20),
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
              'Welcome',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'we send a 6-digit code to   ',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: widget.number,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneAuthScreen()));
                  },
                  child: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: _text1,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (value) {
                      if (value.length == 1) {
                        node.nextFocus();
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: _text2,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (value) {
                      if (value.length == 1) {
                        node.nextFocus();
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: _text3,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (value) {
                      if (value.length == 1) {
                        node.nextFocus();
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: _text4,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (value) {
                      if (value.length == 1) {
                        node.nextFocus();
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: _text5,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (value) {
                      if (value.length == 1) {
                        node.nextFocus();
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: _text6,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (value) {
                      if (value.length == 1) {
                        if (_text1.text.length == 1) {
                          if (_text2.text.length == 1) {
                            if (_text3.text.length == 1) {
                              if (_text4.text.length == 1) {
                                if (_text5.text.length == 1) {
                                  String otp = '${_text1.text}${_text2.text}${_text3.text}${_text4.text}${_text5.text}${_text6.text}';
                                  phoneCredential(context, otp);
                                  setState(() {
                                    _loading = true;
                                  });
                                }
                              }
                            }
                          }
                        }
                      } else {
                        setState(() {
                          _loading = false;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 18,
            ),
            if (_loading)
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                    width: 80,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    )),
              ),
            const SizedBox(
              height: 18,
            ),
            Text(error, style: const TextStyle(color: Colors.red, fontSize: 12))
          ],
        ),
      ),
    );
  }
}
