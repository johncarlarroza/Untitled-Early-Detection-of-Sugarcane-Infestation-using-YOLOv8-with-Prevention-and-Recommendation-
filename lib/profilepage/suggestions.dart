import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Suggestions extends StatefulWidget {
  const Suggestions({super.key});

  @override
  State<Suggestions> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Suggestions> {
  TextEditingController nameController = TextEditingController();
  TextEditingController jobController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("Puser");
  final CollectionReference locationsCollection =
      FirebaseFirestore.instance.collection("locations");
  final CollectionReference pcCollection =
      FirebaseFirestore.instance.collection("pc");

  String email = "";
  String placeName = "Not available";
  List<String> pestsCaptured = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? "Not available";
      });

      // Fetch placeName from "locations" collection
      DocumentSnapshot locationDoc =
          await locationsCollection.doc(user.uid).get();
      if (locationDoc.exists) {
        setState(() {
          placeName = locationDoc['placeName'] ?? "Not available";
        });
      }

      // Fetch pest image URLs from "pc" collection's "pcaptured" document
      DocumentSnapshot pcDoc = await pcCollection.doc(user.uid).get();
      if (pcDoc.exists) {
        if (pcDoc['pcaptured'] != null && pcDoc['pcaptured'] is List) {
          setState(() {
            pestsCaptured = List<String>.from(pcDoc['pcaptured']);
          });
        } else {
          // Handle the case where the field is not a list
          setState(() {
            pestsCaptured = [];
          });
        }
      }

      // Fetch username and userType from "users" collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          // Assuming 'username' and 'userType' are fields in the "users" collection
          nameController.text = userDoc['username'] ?? "Not available";
          jobController.text = userDoc['userType'] ?? "Not available";
        });
      }
    }
  }

  Future<void> savePestImages(List<String> imageUrls) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await pcCollection.doc(user.uid).set({
        'pcaptured': imageUrls,
      });
    }
  }

  Future<void> storeData() async {
    String name = nameController.text;
    String job = jobController.text;
    String description = descriptionController.text;

    if (name.isNotEmpty && job.isNotEmpty && description.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          await FirebaseFirestore.instance.collection("reports").add({
            'userId': user.uid,
            'name': name,
            'email': email,
            'location': placeName,
            'job': job,
            'description': description,
            'pestsCaptured': pestsCaptured,
            'timestamp': FieldValue.serverTimestamp(),
          });

          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Report saved successfully!")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save report: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Add Reports",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSuggestionForm,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showSuggestionForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return myDialogBox(context: context, onPressed: storeData);
      },
    );
  }

  Dialog myDialogBox({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                const Text(
                  "Add Suggestion",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                ),
              ],
            ),
            commonTextField("Name", nameController),
            commonTextField("Job", jobController),
            commonTextField("Description", descriptionController),
            const SizedBox(height: 12),
            readOnlyTextField("Email", email),
            readOnlyTextField("Location", placeName),
            imageGrid("Pests Captured", pestsCaptured),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding commonTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Padding readOnlyTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        enabled: false,
        initialValue: value,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget imageGrid(String label, List<String> imageUrls) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, color: Colors.grey);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
