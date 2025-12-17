import 'package:early_application_1/location/geolocation.dart';
import 'package:early_application_1/pages/signin_screen.dart';
import 'package:early_application_1/profilepage/gallery.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editprofile.dart'; // Import the EditProfilePage
import 'suggestions.dart'; // Import the SuggestionsPage
import 'appinfo.dart'; // Import the AppInfoPage

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  String? _username;
  String? _email;
  String? _placeName;
  String? _userType;
  String? _profilePictureUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserProfile();
  }

  // Fetch user profile from Firestore
  Future<void> _fetchUserProfile() async {
    // Fetch email from Firebase Auth
    setState(() {
      _email = _user?.email ?? 'Unknown';
    });

    // Fetch the user's profile data from Firestore (users collection)
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user?.uid) // Using the UID of the logged-in user
          .get();

      if (userDoc.exists) {
        setState(() {
          _username = userDoc['username']; // Get username from Firestore
          _userType = userDoc['userType']; // Get user type from Firestore
          _profilePictureUrl = userDoc[
              'profilePictureUrl']; // Get profile picture URL from Firestore
        });
      } else {
        setState(() {
          _username = 'Unknown';
          _userType = 'Unknown';
          _profilePictureUrl = null;
        });
      }

      // Fetch the placeName from Firestore (locations collection)
      DocumentSnapshot locationDoc = await FirebaseFirestore.instance
          .collection('locations')
          .doc(_user?.uid) // Using the UID of the logged-in user
          .get();

      if (locationDoc.exists) {
        setState(() {
          _placeName =
              locationDoc['placeName']; // Retrieve placeName from Firestore
          _isLoading = false;
        });
      } else {
        setState(() {
          _placeName = "Location not available"; // Default message
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      setState(() {
        _placeName = "Location not available";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Center the profile picture and username
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profilePictureUrl != null
                            ? NetworkImage(_profilePictureUrl!)
                            : AssetImage('assets/profilepic.png')
                                as ImageProvider,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Information Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: Colors.grey.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Username',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _username ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.email, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _email ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Location',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _placeName ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.person_add, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'User Type',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userType ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    // Edit Profile, Location, Suggestions, and App Info ListTile
                    _buildListTile(
                      icon: Icons.location_on,
                      title: 'Location',
                      onTap: () => _navigateToLocation(context),
                    ),

                    _buildListTile(
                      icon: Icons.info_outline,
                      title: 'Charts',
                      onTap: () => _navigateToCharts(context),
                    ),
                    _buildListTile(
                      icon: Icons.info_outline,
                      title: 'Gallery',
                      onTap: () => _navigateToGallery(context),
                    ),
                    _buildListTile(
                      icon: Icons.info_outline,
                      title: 'App Info',
                      onTap: () => _navigateToAppInfo(context),
                    ),
                    const SizedBox(height: 16),
                    // Log Out Button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () => _logout(context),
                          child: const Text('Log Out'),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Helper function to build list tiles
  ListTile _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      onTap: onTap,
    );
  }

  // Navigate to Edit Profile Page
  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }

  // Navigate to Location Page
  void _navigateToLocation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPage(),
      ), // Ensure LocationPage is defined
    );
  }

  // Navigate to App Info Page
  void _navigateToAppInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppInfoPage()),
    );
  }

  void _navigateToGallery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GalleryPage()),
    );
  }

  void _navigateToCharts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GalleryPage()),
    );
  }

  // Logout function
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => SignInScreen()), // your sign-in page
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }
}
