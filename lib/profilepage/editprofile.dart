import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;

  Future<void> uploadImageAndData() async {
    // Pick an image
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // Get the file
    File file = File(pickedFile.path);

    // Create a reference to Firebase Storage
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageRef = storage
        .ref()
        .child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Upload the file
    try {
      await storageRef.putFile(file);

      // Get the download URL of the file
      String downloadURL = await storageRef.getDownloadURL();

      // Store the download URL in Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc('user-id').update({
        'profileImageUrl': downloadURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _imageUrl = downloadURL;
      });

      print("File uploaded and Firestore updated!");
    } catch (e) {
      print("Error uploading file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the image if available
            _imageUrl == null
                ? const Text('No image selected')
                : Image.network(_imageUrl!),

            const SizedBox(height: 20),

            // Button to pick and upload image
            ElevatedButton(
              onPressed: uploadImageAndData,
              child: const Text('Pick and Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
