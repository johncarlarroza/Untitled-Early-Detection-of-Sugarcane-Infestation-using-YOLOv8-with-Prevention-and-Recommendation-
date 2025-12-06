import 'package:flutter/material.dart';
import 'editprofile.dart'; // Import the EditProfilePage
import 'suggestions.dart'; // Import the SuggestionsPage
import 'appinfo.dart'; // Import the AppInfoPage

class OffProfilePage extends StatelessWidget {
  const OffProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(''), automaticallyImplyLeading: false),
      body: ListView(
        children: [
          // Edit Profile ListTile
          // ListTile(
          //   leading: const Icon(Icons.edit),
          //   title: const Text('Edit Profile'),
          //   onTap: () {
          //     _navigateToEditProfile(context); // Navigate to Edit Profile page
          //   },
          // ),
          const Divider(), // Add a line separator between items
          // Suggestion ListTile
          // ListTile(
          //   leading: const Icon(Icons.lightbulb_outline),
          //   title: const Text('Suggestion'),
          //   onTap: () {
          //     _navigateToSuggestion(context); // Navigate to Suggestion page
          //   },
          // ),
          // const Divider(), // Add a line separator between items

          // App Info ListTile
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Info'),
            onTap: () {
              _navigateToAppInfo(context); // Navigate to App Info page
            },
          ),
          const Divider(), // Add a line separator between items
        ],
      ),
    );
  }

  // // Navigation methods
  // void _navigateToEditProfile(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const EditProfilePage()),
  //   );
  // }

  // void _navigateToSuggestion(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => Suggestions()),
  //   );
  // }

  void _navigateToAppInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppInfoPage()),
    );
  }
}
