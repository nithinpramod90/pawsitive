import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/authentication/password%20reset%20screen.dart';
import 'package:pawsitive/services/emailauth_service.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});
  static const String id = 'emailAut-screen';
  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final _formkey = GlobalKey<FormState>();
  bool _validate = false;
  bool _login = true;
  bool _loading = false;
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final EmailAuthentication _service = EmailAuthentication();
  _validateEmail() {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _validate = false;
        _loading = true;
      });
      _service
          .getAdminCredential(
        context: context,
        isLog: _login,
        password: _passwordcontroller.text,
        email: _emailcontroller.text,
      )
          .then((value) {
        setState(() {
          _loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          _login ? 'Login' : 'Register',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Form(
        key: _formkey,
        child: Padding(
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
              Text(
                'Enter to ${_login ? 'Login' : 'Register'}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Enter your email and password to ${_login ? 'Login' : 'Register'}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _emailcontroller,
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
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  labelText: ' Email',
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                obscureText: true,
                controller: _passwordcontroller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  labelText: ' Password',
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                ),
                onChanged: (value) {
                  if (_emailcontroller.text.isNotEmpty) {
                    if (value.length > 3) {
                      setState(() {
                        _validate = true;
                      });
                    } else {
                      setState(() {
                        _validate = false;
                      });
                    }
                  }
                },
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Text(
                    _login ? 'New account?' : 'Already has an account?',
                    textAlign: TextAlign.left,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _login = !_login;
                      });
                    },
                    child: Text(
                      _login ? 'Register' : 'Login',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, PasswordResetScreen.id);
                        },
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: AbsorbPointer(
            absorbing: _validate ? false : true,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: _validate ? MaterialStateProperty.all(const Color(0xFF846A85)) : MaterialStateProperty.all(Colors.grey),
              ),
              onPressed: () {
                _validateEmail();
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _login ? 'Login' : 'Register',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
