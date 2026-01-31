import 'dart:io';

import 'package:early_application_1/features/app/splash_screen/splash_screen.dart';
import 'package:early_application_1/features/user_auth/presentation/pages/home_page.dart';
import 'package:early_application_1/pages/signin_screen.dart';
import 'package:early_application_1/pages/signup_screen.dart';
import 'package:flutter/material.dart';
import 'camera/camera.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyAxM_3fNEmrYptgcyUPbQz_c5_ocQLroLQ",
            appId: "1:836401596768:android:1d923a59fb3a20e5187605",
            messagingSenderId: "836401596768",
            projectId: "earlydetectionofsugarcanepest",
            storageBucket: "earlydetectionofsugarcanepest.firebasestorage.app",
          ),
        )
      : await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  FirebaseAuth.instance.setLanguageCode('en');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pestecane',
      routes: {
        '/': (context) => const SplashScreen(child: SignInScreen()),
        '/login': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
