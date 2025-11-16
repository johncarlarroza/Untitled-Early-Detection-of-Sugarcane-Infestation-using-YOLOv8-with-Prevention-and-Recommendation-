import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OffCamera extends StatefulWidget {
  const OffCamera({Key? key}) : super(key: key);

  @override
  State<OffCamera> createState() => _CameraPageState();
}

class _CameraPageState extends State<OffCamera> {
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

  String? _getPestDescription(String label) {
    const descriptions = {
      "Coconut Rhinoceros Beetle":
          "The Coconut Rhinoceros Beetle is a destructive pest known for its distinctive horn.",
      "Coconut Leaf Beetle":
          "The coconut leaf beetle is one of the most damaging pests of coconut and other palms. The larvae and adults of the beetle feed on the soft tissues of the youngest leaf in the throat of the palm. ",
      "Coconut Scale Insect":
          "The Coconut Scale Insect is a sap-sucking pest that infests coconut palms.",
      "Unclassified": "Unable to classify this pest. Please try another image.",
    };
    return descriptions[label];
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

  void _saveData() {
    print("Save Data clicked");
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
    return Scaffold(
      body: Stack(
        children: [
          if (_isCameraInitialized)
            SizedBox.expand(child: CameraPreview(_cameraController!))
          else
            const Center(child: CircularProgressIndicator()),

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
                      width: 350,
                      height: 600,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          // Wrap the Column in SingleChildScrollView
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
                              if (_label != null)
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
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
                                      if (_description != null)
                                        Text(
                                          _description!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      const SizedBox(height: 12),
                                      // Add three separate text blocks below
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
                                      const SizedBox(height: 8),
                                      Text(
                                        'Mitigation: Control measures include the use of pheromone traps to capture adult beetles, biological control using entomopathogenic fungi, and cultural practices such as removing and destroying breeding sites. Chemical control can also be effective but is generally used as a last resort.',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: _viewFullDetails,
                                    child: const Text("View Full Details"),
                                  ),
                                  ElevatedButton(
                                    onPressed: _saveData,
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
