import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  User? _user;
  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserImages();
  }

  // Fetch images from the 'pc' collection
  Future<void> _fetchUserImages() async {
    try {
      // Fetch the user's image URLs from the 'pc' collection
      QuerySnapshot imageQuery = await FirebaseFirestore.instance
          .collection('pc')
          .where('userId', isEqualTo: _user?.uid) // Ensure the user ID matches
          .get();

      print('Fetched ${imageQuery.docs.length} images.');

      if (imageQuery.docs.isNotEmpty) {
        setState(() {
          _imageUrls =
              imageQuery.docs.map((doc) => doc['imageUrl'] as String).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _imageUrls = [];
          _isLoading = false;
        });
      }

      // Debug: Print all the fetched image URLs
      print('Image URLs: $_imageUrls');
    } catch (e) {
      print("Error fetching images: $e");
      setState(() {
        _imageUrls = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Display user's email or a default message if not available
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'User: ${_user?.email ?? 'No email available'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                // If no images are available, show a message
                _imageUrls.isEmpty
                    ? const Center(
                        child: Text(
                          'No photos available.',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      )
                    : Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(10),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _imageUrls.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(_imageUrls[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}
