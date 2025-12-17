import 'package:early_application_1/AdBasepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/color_utils.dart';
import '../reusable_widgets/reusable_widget.dart';
import 'admin_dashboard.dart';
import 'package:early_application_1/pages/signin_screen.dart';

class AdminSignInPage extends StatefulWidget {
  const AdminSignInPage({Key? key}) : super(key: key);

  @override
  _AdminSignInPageState createState() => _AdminSignInPageState();
}

class _AdminSignInPageState extends State<AdminSignInPage> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  void _adminSignIn() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('aduser', isEqualTo: _emailTextController.text.trim())
          .where('adpass', isEqualTo: _passwordTextController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin logged in successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminBasePage()),
        );
      } else {
        // No match found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid admin username or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin login failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("FFB300"), // strong yellow
              hexStringToColor("FF6F00"), // deep warm orange
              hexStringToColor("D84315"), // reddish orange
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                const Text(
                  "Admin Portal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                logoWidget("assets/adminlogo.png"),
                const SizedBox(height: 30),
                reusableTextField(
                  "Admin Username",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(height: 20),
                firebaseUIButton(context, "Admin Sign In", _adminSignIn),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                      (route) => false, // removes all previous routes
                    );
                  },
                  child: const Text(
                    "Back to User Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }
}
