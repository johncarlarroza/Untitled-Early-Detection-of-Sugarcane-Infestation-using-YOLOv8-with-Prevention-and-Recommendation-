import 'dart:io';

import 'package:early_application_1/features/app/splash_screen/splash_screen.dart';
import 'package:early_application_1/pages/signin_screen.dart';
import 'package:flutter/material.dart';
import 'camera/camera.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'features/user_auth/presentation/pages/sign_up_page.dart';
import 'pages/home.dart'; // Import Firebase Auth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyDT-I2rSCWxEulGhVdPm-7Yq19uuOShdFs",
            appId: "1:668698779658:android:2f4bf28f2d2bd9d511bff3",
            messagingSenderId: "668698779658",
            projectId: "pestincocoonfirebase",
            storageBucket: "pestincocoonfirebase.firebasestorage.app",
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
      title: 'PestinCoco',
      routes: {
        '/': (context) => const SplashScreen(child: SignInScreen()),
        '/login': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
