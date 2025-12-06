import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  File? _image;
  String? _label;
  double? _confidence;
  String? _description;
  bool _isCameraInitialized = false;
  bool _isImageClassified = false;
  int _selectedCameraIndex = 0;
  List<CameraDescription>? _cameras;
  FlashMode _flashMode = FlashMode.off;
  bool _isImagePickerActive = false;
  List<String> imageUrls = [];
  final double focusBoxWidth = 250.0; // Width of the focus box
  final double focusBoxHeight = 250.0; // Height of the focus box
  double focusBoxTop =
      1500.0; // Vertical position of the box (adjust as needed)
  double focusBoxLeft =
      150.0; // Horizontal position of the box (adjust as needed)

  Future<void> _tfLiteInit() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> _classifyImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );

    if (!mounted) return;

    if (recognitions == null || recognitions.isEmpty) {
      setState(() {
        _label = "Unclassified";
        _confidence = null;
        _description = null;
      });
      return;
    }

    String detectedLabel = recognitions[0]['label'].toString();
    _description = _getPestDescription(detectedLabel);

    setState(() {
      _label = detectedLabel;
      _confidence = recognitions[0]['confidence'] * 100;
      _isImageClassified = true;
    });
  }

  // Function to get pest description based on the detected label
  String? _getPestDescription(String? label) {
    switch (label) {
      case "0 Coconut Rhinoceros Beetle":
        return "The Coconut Rhinoceros Beetle is a destructive pest known for its distinctive horn.";
      case "1 Coconut Leaf Beetle":
        return "The coconut leaf beetle is one of the most damaging pests of coconut and other palms. The larvae and adults of the beetle feed on the soft tissues of the youngest leaf in the throat of the palm.";
      case "2 Coconut Scale Insect":
        return "The Coconut Scale Insect is a sap-sucking pest that infests coconut palms.";
      case "3 Unclassified":
        return "Unable to classify this pest. Please try another image.";
      default:
        return "";
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController?.initialize();
      if (!mounted) return;

      await _cameraController?.setFlashMode(_flashMode);
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    try {
      final XFile file = await _cameraController!.takePicture();
      if (!mounted) return;

      setState(() {
        _image = File(file.path);
        _label = null;
        _confidence = null;
        _description = null;
        _isImageClassified = false;
      });
      await _classifyImage(_image!);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getImageFromGallery() async {
    if (_isImagePickerActive) return; // Check if picker is already active
    setState(() {
      _isImagePickerActive = true; // Set flag to true
    });

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _isImagePickerActive = false; // Reset flag after picking
    });

    if (image == null || !mounted) return;

    setState(() {
      _image = File(image.path);
      _label = null;
      _confidence = null;
      _description = null;
      _isImageClassified = false;
    });

    await _classifyImage(_image!);
  }

  Future<void> _switchCamera() async {
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    await _initializeCamera();
  }

  void _toggleFlash() {
    setState(() {
      _flashMode = _flashMode == FlashMode.off
          ? FlashMode.torch
          : FlashMode.off;
    });
    _cameraController?.setFlashMode(_flashMode);
  }

  void _resetClassification() {
    setState(() {
      _isImageClassified = false;
      _image = null;
      _label = null;
      _confidence = null;
      _description = null;
    });
  }

  void _viewFullDetails() {
    print("View Full Details clicked");
  }

  // Save data to Firestore

  Future<void> _saveData() async {
    if (_image == null) return;

    try {
      // Upload the image to Firebase Storage and get the download URL
      String? imageUrl = await _uploadImageToFirebase(_image!);

      if (imageUrl != null) {
        // Get the current user ID and email from FirebaseAuth
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        String? email = FirebaseAuth.instance.currentUser?.email;
        if (userId == null || email == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User is not logged in")),
          );
          return;
        }

        // Fetch the user's location (placeName) from Firestore
        DocumentSnapshot locationSnapshot = await FirebaseFirestore.instance
            .collection('locations')
            .doc(userId)
            .get();
        String placeName = locationSnapshot.exists
            ? locationSnapshot['placeName'] ?? "Unknown Location"
            : "Unknown Location";

        // Fetch user data from the 'users' collection (userType and username)
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        String userType = userSnapshot.exists
            ? userSnapshot['userType'] ?? "Unknown"
            : "Unknown";
        String username = userSnapshot.exists
            ? userSnapshot['username'] ?? "Anonymous"
            : "Anonymous";

        // Save data to Firestore
        await FirebaseFirestore.instance.collection("pc").doc(userId).set({
          'imageUrl': imageUrl, // Store the image URL
          'label': _label ?? "Unclassified", // Store the label
          'confidence': _confidence ?? 0.0, // Store the confidence value
          'description': _description ?? "No description", // Store description
          'timestamp': FieldValue.serverTimestamp(), // Store timestamp
          'placeName': placeName, // Store location name
          'email': email, // Store email
          'userType': userType, // Store user type
          'username': username, // Store username
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data saved successfully.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving data: $e")));
    }
  }

  Future<void> _classifyAndSaveImage(File image) async {
    // Upload the image to the "Saved Image" folder and get the download URL
    String? downloadUrl = await _uploadImageToFirebase(image);

    if (downloadUrl != null) {
      // Append the new download URL to the class-level imageUrls list
      imageUrls.add(downloadUrl);
      await _saveData(); // Save the data to Firestore
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    int attempts = 0;
    const maxAttempts = 5;
    while (attempts < maxAttempts) {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child(
          "pest_images/$fileName",
        );
        UploadTask uploadTask = storageRef.putFile(image);

        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        print("Error uploading image: $e");
        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(
            Duration(seconds: 2 << attempts),
          ); // Exponential backoff
        }
      }
    }
    return null;
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Help"),
          content: Image.asset('assets/tips.png'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tfLiteInit();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double focusBoxWidth = 250.0; // Set a larger width
    double focusBoxHeight = 400.0; // Set a larger height
    // Calculate the position of the focus box (center it)
    double focusBoxTop = (screenHeight - focusBoxHeight) / 4;
    double focusBoxLeft = (screenWidth - focusBoxWidth) / 2;

    return Scaffold(
      body: Stack(
        children: [
          if (_isCameraInitialized)
            SizedBox.expand(child: CameraPreview(_cameraController!))
          else
            const Center(child: CircularProgressIndicator()),
          // Focus Box (Rectangular area)
          Positioned(
            top: focusBoxTop,
            left: focusBoxLeft,
            child: Container(
              width: focusBoxWidth,
              height: focusBoxHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Top left icons: Flash and Switch Camera
          Positioned(
            top: 40,
            left: 16,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _flashMode == FlashMode.torch
                        ? Icons.flash_on
                        : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFlash,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.switch_camera, color: Colors.white),
                  onPressed: _switchCamera,
                ),
              ],
            ),
          ),

          // Bottom controls: Photo, Capture, and Help
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      onPressed: _getImageFromGallery,
                      tooltip: 'Pick from Gallery',
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.photo, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Photos",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),

                // Capture button
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.lightBlueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: _captureImage,
                    tooltip: 'Capture Image',
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),

                // Help button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      onPressed: _showHelpDialog,
                      tooltip: 'Help',
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.help_outline,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Snap Tips",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Classification card overlay
          if (_isImageClassified)
            GestureDetector(
              onTap: _resetClassification,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    elevation: 20,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: 380,
                      height: 500,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 280,
                                    width: 280,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      image: _image == null
                                          ? const DecorationImage(
                                              image: AssetImage(
                                                'assets/upload.jpg',
                                              ),
                                            )
                                          : DecorationImage(
                                              image: FileImage(_image!),
                                              fit: BoxFit.fill,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: _resetClassification,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_label != null && _label!.isNotEmpty)
                                Text(
                                  _label!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(height: 12),
                              if (_confidence != null)
                                Text(
                                  "The Accuracy is ${_confidence!.toStringAsFixed(0)}%",
                                  style: const TextStyle(fontSize: 18),
                                ),
                              const SizedBox(height: 12),

                              // Display description based on the insect detected
                              if (_label != null && _label != "0 Unclassified")
                                Text(
                                  _getPestDescription(
                                    _label,
                                  )!, // No need to check null here as we already handle it
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              const SizedBox(height: 12),

                              // Additional pest-related info (if needed)
                              if (_label == "1 Coconut Rhinoceros Beetle") ...[
                                Text(
                                  'The coconut rhinoceros beetle (Oryctes rhinoceros) is a species of beetle in the Scarabaeidae family. It is a major pest of coconut palms, attacking the growing shoots of the palms, which can lead to reduced fruit production and even the death of the trees.',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Adult beetles bore into the crowns of coconut palms and feed on the sap. This boring can cause significant damage to the palms, creating entry points for pathogens. The larvae develop in decaying organic matter, such as dead palm trunks and compost heaps',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ] else if (_label == "2 Coconut Leaf Beetle") ...[
                                Text(
                                  'Coconut leaf beetles cause severe damage to coconut palms by feeding on the soft tissue of young leaves. The damage may stunt the growth of the palm and result in reduced yields.',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ] else if (_label ==
                                  "3 Coconut Scale Insect") ...[
                                Text(
                                  'The Coconut Scale Insect feeds on the sap of coconut palms, causing yellowing of leaves and weakening the tree, making it more susceptible to other diseases.',
                                  style: const TextStyle(
                                    fontSize: 162,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Save the data when the button is pressed
                                      await _saveData();
                                    },
                                    child: const Text("Save Data"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
