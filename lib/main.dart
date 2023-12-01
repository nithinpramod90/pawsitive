import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pawsitive/donation_item/product_by_category_screen.dart';
import 'package:pawsitive/firebase_options.dart';
import 'package:pawsitive/screens/authentication/email_auth_screen.dart';
import 'package:pawsitive/screens/authentication/email_verification_screen.dart';
import 'package:pawsitive/screens/authentication/password%20reset%20screen.dart';
import 'package:pawsitive/screens/authentication/phoneauth_screen.dart';
import 'package:pawsitive/screens/form/donation_form.dart';
import 'package:pawsitive/screens/form/user_reviw_screen.dart';
import 'package:pawsitive/screens/home_screen.dart';
import 'package:pawsitive/screens/location_screen.dart';
import 'package:pawsitive/screens/login_screen.dart';
import 'package:pawsitive/screens/main_screen.dart';
import 'package:pawsitive/screens/product_details_screen.dart';
import 'package:pawsitive/screens/provider/cat_provider.dart';
import 'package:pawsitive/screens/provider/product_provider.dart';
import 'package:pawsitive/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Provider.debugCheckInvalidValueType = null;
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => CategoryProvider()),
        Provider(create: (_) => ProductProvider()),

        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: const Color(0xFF846A85),
        fontFamily: 'Lato',
      ),
      initialRoute: SplashScreen.id,
      routes: {
        LoginScreen.id: (context) => const LoginScreen(),
        SplashScreen.id: (context) => const SplashScreen(),
        PhoneAuthScreen.id: (context) => const PhoneAuthScreen(),
        LocationScreen.id: (context) => LocationScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        EmailAuthScreen.id: (context) => const EmailAuthScreen(),
        EmailVerificationScreen.id: (context) => const EmailVerificationScreen(),
        PasswordResetScreen.id: (context) => const PasswordResetScreen(),
        MainScreen.id: (context) => const MainScreen(),
        DonationForm.id: (context) => const DonationForm(),
        UserReviewScreen.id: (context) => const UserReviewScreen(),
        ProductDetails.id: (context) => const ProductDetails(),
        ProductByCategory.id: (context) => const ProductByCategory(),
      },
    );
  }
}
