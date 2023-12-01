import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/screens/chat/chat_screen.dart';
import 'package:pawsitive/screens/form/donation_form.dart';
import 'package:pawsitive/screens/home_screen.dart';
import 'package:pawsitive/screens/login_screen.dart';
import 'package:pawsitive/screens/myad_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const String id = 'main-screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _currentScreen = const HomeScreen();
  int _index = 0;
  final PageStorageBucket _bucket = PageStorageBucket();
  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageStorage(
        bucket: _bucket,
        child: _currentScreen,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade400,
        onPressed: () {
          Navigator.pushNamed(context, DonationForm.id);
        },
        shape: const CircleBorder(),
        child: const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 111, 54, 197),
          child: Icon(
            Icons.add,
          ),
        ), // Adjust this as needed
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade100,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        _index = 0;
                        _currentScreen = const HomeScreen();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _index == 0 ? Icons.home : Icons.home_outlined,
                        ),
                        Text(
                          'Home',
                          style: TextStyle(
                            color: _index == 0 ? color : Colors.black,
                            fontWeight: _index == 0 ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        _index = 1;
                        _currentScreen = const ChatScreen();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _index == 1 ? CupertinoIcons.chat_bubble_fill : CupertinoIcons.chat_bubble,
                        ),
                        Text(
                          'Chats',
                          style: TextStyle(
                            color: _index == 1 ? color : Colors.black,
                            fontWeight: _index == 1 ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        _index = 2;
                        _currentScreen = const MyAdsScreen();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_index == 2 ? CupertinoIcons.heart_fill : CupertinoIcons.heart),
                        Text(
                          'Donations',
                          style: TextStyle(
                            color: _index == 2 ? color : Colors.black,
                            fontWeight: _index == 2 ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() async {
                        await Navigator.pushReplacementNamed(context, LoginScreen.id);
                        FirebaseAuth.instance.signOut();
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _index == 3 ? Icons.login_outlined : Icons.logout,
                        ),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: _index == 3 ? color : Colors.black,
                            fontWeight: _index == 3 ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
