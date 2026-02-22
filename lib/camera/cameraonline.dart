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

  String?
      _label; // will store RAW label from model (or normalized display label)
  double? _confidence;

  // You were using only one description string in Firestore
  String? _description;

  bool _isCameraInitialized = false;
  bool _isImageClassified = false;

  int _selectedCameraIndex = 0;
  List<CameraDescription>? _cameras;

  FlashMode _flashMode = FlashMode.off;
  bool _isImagePickerActive = false;

  // if you want to store multiple saved URLs (you had this)
  List<String> imageUrls = [];

  // Focus box settings (you can keep these)
  final double focusBoxWidth = 250.0;
  final double focusBoxHeight = 250.0;

  // optional: confidence threshold
  static const double _minConfidenceToAccept = 45.0; // 45%

  // ✅ Your long descriptions (same as you wrote)
  static const Map<String, Map<String, String>> _pestInfo = {
    "Cocoa Pod Borrer": {
      "title": "Cocoa Pod Borer",
      "desc":
          "A tiny moth pest whose baby stage (larva) drills into cacao pods.",
      "details":
          "This is one of the most harmful pests for cacao farmers, especially in tropical regions. It damages the beans inside and lowers harvest quality.",
      "biology":
          "The adult moth lays eggs on the pod surface. When the eggs hatch, the larvae bore inside and feed on the beans.",
      "control":
          "Harvest pods regularly, remove infested pods, use pheromone traps, and encourage natural enemies like parasitoid wasps.",
    },
    "Cocoa Mirid Bug": {
      "title": "Cocoa Mirid Bug",
      "desc": "A small insect that sucks sap from cacao stems and pods.",
      "details":
          "Their feeding creates wounds that can turn into dark lesions and may cause branches to dry up.",
      "biology":
          "They usually feed at night and inject toxins while sucking plant sap.",
      "control":
          "Trim damaged parts, keep the plantation clean, and use recommended insecticides when needed.",
    },
    "Cocoa Mealy Bugs": {
      "title": "Cocoa Mealy Bugs",
      "desc": "Tiny white insects that look like they’re covered in cotton.",
      "details":
          "They weaken plants by sucking sap and can also spread diseases. Ants often protect them.",
      "biology":
          "They gather in groups on stems, leaves, and pods and multiply quickly.",
      "control":
          "Control ants, wash them off with water, or use natural sprays like neem oil.",
    },
    "Unclassified": {
      "title": "Unclassified",
      "desc": "There is no pest in the picture captured.",
      "details": "",
      "biology": "",
      "control": "",
    }
  };

  Future<void> _tfLiteInit() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  // Normalize raw label from TFLite to your canonical keys:
  // Cocoa Mealy Bugs / Cocoa Mirid Bug / Cocoa Pod Borrer / Unclassified
  String _normalizeLabel(String raw) {
    final cleaned = raw.toLowerCase().trim();

    // Prefer index-based match because your labels include numbers
    if (cleaned.startsWith('0')) return 'Cocoa Mealy Bugs';
    if (cleaned.startsWith('1')) return 'Cocoa Mirid Bug';
    if (cleaned.startsWith('2')) return 'Cocoa Pod Borrer';
    if (cleaned.startsWith('3')) return 'Unclassified';

    // fallback keyword match
    if (cleaned.contains('mealy')) return 'Cocoa Mealy Bugs';
    if (cleaned.contains('mirid')) return 'Cocoa Mirid Bug';
    if (cleaned.contains('borrer') || cleaned.contains('borer')) {
      return 'Cocoa Pod Borrer';
    }
    if (cleaned.contains('unclassified') || cleaned.contains('unknown')) {
      return 'Unclassified';
    }

    return 'Unclassified';
  }

  // Your old method name kept, but corrected for Cocoa labels
  String _getPestDescription(String? rawLabel) {
    final normalized = _normalizeLabel(rawLabel ?? '');
    final info = _pestInfo[normalized] ?? _pestInfo["Unclassified"]!;

    // This string is what will be saved to Firestore as "description"
    if (normalized == "Unclassified") {
      return info["desc"] ?? "There is no pest in the picture captured.";
    }

    return "Description: ${info["desc"]}\n\n"
        "Detailed Information: ${info["details"]}\n\n"
        "Biology and Behavior: ${info["biology"]}\n\n"
        "Control Measures: ${info["control"]}";
  }

  Future<void> _classifyImage(File image) async {
    final recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 3,
      threshold: 0.2,
      asynch: true,
    );

    if (!mounted) return;

    if (recognitions == null || recognitions.isEmpty) {
      setState(() {
        _label = "Unclassified";
        _confidence = null;
        _description = _getPestDescription("Unclassified");
        _isImageClassified = true;
      });
      return;
    }

    final rawLabel = (recognitions[0]['label'] ?? '').toString();
    final conf01 = (recognitions[0]['confidence'] ?? 0.0) as double;
    final conf = conf01 * 100;

    final normalized = _normalizeLabel(rawLabel);

    // If low confidence OR model outputs Unclassified -> Unclassified
    final finalLabel =
        (normalized == "Unclassified" || conf < _minConfidenceToAccept)
            ? "Unclassified"
            : normalized;

    setState(() {
      _label = finalLabel; // store normalized for UI
      _confidence = conf;
      _description = _getPestDescription(finalLabel);
      _isImageClassified = true;
    });
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    // dispose old controller before re-init (important when switching camera)
    await _cameraController?.dispose();

    _cameraController = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController?.initialize();
      if (!mounted) return;

      await _cameraController?.setFlashMode(_flashMode);
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

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
      debugPrint("Capture error: $e");
    }
  }

  Future<void> _getImageFromGallery() async {
    if (_isImagePickerActive) return;

    setState(() => _isImagePickerActive = true);

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (!mounted) return;
    setState(() => _isImagePickerActive = false);

    if (image == null) return;

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
    if (_cameras == null || _cameras!.length < 2) return;
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    setState(() => _isCameraInitialized = false);
    await _initializeCamera();
  }

  void _toggleFlash() {
    if (_cameraController == null) return;

    setState(() {
      _flashMode =
          _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
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

  // ----------------- FIRESTORE SAVE -----------------

  Future<void> _saveData() async {
    if (_image == null) return;

    try {
      final imageUrl = await _uploadImageToFirebase(_image!);

      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload image.")),
        );
        return;
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      final email = FirebaseAuth.instance.currentUser?.email;

      if (userId == null || email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User is not logged in")),
        );
        return;
      }

      // location (optional)
      final locationSnapshot = await FirebaseFirestore.instance
          .collection('locations')
          .doc(userId)
          .get();

      final placeName = locationSnapshot.exists
          ? (locationSnapshot.data()?['placeName'] ?? "Unknown Location")
          : "Unknown Location";

      // user profile (optional)
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userType = userSnapshot.exists
          ? (userSnapshot.data()?['userType'] ?? "Unknown")
          : "Unknown";

      final username = userSnapshot.exists
          ? (userSnapshot.data()?['username'] ?? "Anonymous")
          : "Anonymous";

      // NOTE: you were using .doc(userId).set => overwrites the same doc per user
      // If you want multiple records, use .add({...}) instead.
      await FirebaseFirestore.instance.collection("pc").add({
        'userId': userId,
        'imageUrl': imageUrl,
        'label': _label ?? "Unclassified",
        'confidence': _confidence ?? 0.0,
        'description': _description ?? "No description",
        'timestamp': FieldValue.serverTimestamp(),
        'placeName': placeName,
        'email': email,
        'userType': userType,
        'username': username,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data saved successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error saving data: $e")));
    }
  }

  Future<void> _classifyAndSaveImage(File image) async {
    final downloadUrl = await _uploadImageToFirebase(image);
    if (downloadUrl != null) {
      imageUrls.add(downloadUrl);
      await _saveData();
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    int attempts = 0;
    const maxAttempts = 5;

    while (attempts < maxAttempts) {
      try {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef =
            FirebaseStorage.instance.ref().child("pest_images/$fileName");

        final uploadTask = storageRef.putFile(image);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        debugPrint("Error uploading image: $e");
        attempts++;

        if (attempts < maxAttempts) {
          await Future.delayed(Duration(seconds: 2 << attempts));
        }
      }
    }
    return null;
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Help"),
        content: Image.asset('assets/tips.png'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // You were re-declaring these; keep but use local values
    const focusBoxWidth = 250.0;
    const focusBoxHeight = 400.0;

    final focusBoxTop = (screenHeight - focusBoxHeight) / 4;
    final focusBoxLeft = (screenWidth - focusBoxWidth) / 2;

    return Scaffold(
      body: Stack(
        children: [
          if (_isCameraInitialized && _cameraController != null)
            SizedBox.expand(child: CameraPreview(_cameraController!))
          else
            const Center(child: CircularProgressIndicator()),

          // Focus box
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

          // Top left buttons
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

          // Bottom controls
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
                    const Text("Photos",
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),

                // Capture button (kept your design)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
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
                    child:
                        const Icon(Icons.camera, color: Colors.white, size: 30),
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
                      child:
                          const Icon(Icons.help_outline, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    const Text("Snap Tips",
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),

          // Classification overlay
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
                      height: 520,
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
                                                  'assets/upload.jpg'),
                                              fit: BoxFit.cover,
                                            )
                                          : DecorationImage(
                                              image: FileImage(_image!),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
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
                                  textAlign: TextAlign.center,
                                ),
                              const SizedBox(height: 10),
                              if (_confidence != null)
                                Text(
                                  "The Accuracy is ${_confidence!.toStringAsFixed(0)}%",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              const SizedBox(height: 12),
                              if (_description != null &&
                                  _description!.trim().isNotEmpty)
                                Text(
                                  _description!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _saveData();
                                    },
                                    child: const Text("Save Data"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Tap outside to close",
                                style: TextStyle(color: Colors.black45),
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
