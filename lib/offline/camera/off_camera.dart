import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';
import 'dart:typed_data';

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

  String? _getPestDescription(String? label) {
    switch (label) {
      case "Coconut Rhinoceros Beetle":
        return "The Coconut Rhinoceros Beetle is a destructive pest known for its distinctive horn.";
      case "Coconut Leaf Beetle":
        return "The coconut leaf beetle is a damaging pest of coconut and other palms. It feeds on soft tissues of young leaves.";
      case "Coconut Scale Insect":
        return "The Coconut Scale Insect is a sap-sucking pest that weakens coconut palms.";
      case "Unclassified":
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
      print("Camera init error: $e");
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
      print("Capture error: $e");
    }
  }

  Future<void> _getImageFromGallery() async {
    if (_isImagePickerActive) return;

    setState(() => _isImagePickerActive = true);

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() => _isImagePickerActive = false);

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

  Future<void> _saveToGallery() async {
    if (_image == null) return;

    try {
      final bytes = await _image!.readAsBytes();

      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(bytes),
        quality: 100,
        name: "pest_image_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result["isSuccess"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image saved to gallery.")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to save image.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving: $e")));
    }
  }

  void _switchCamera() async {
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

    double focusBoxWidth = 250.0;
    double focusBoxHeight = 400.0;

    double focusBoxTop = (screenHeight - focusBoxHeight) / 4;
    double focusBoxLeft = (screenWidth - focusBoxWidth) / 2;

    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized)
            SizedBox.expand(child: CameraPreview(_cameraController!))
          else
            const Center(child: CircularProgressIndicator()),

          // Focus Box
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

          // Top buttons
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
                FloatingActionButton(
                  onPressed: _getImageFromGallery,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.photo, color: Colors.black),
                ),
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
                  ),
                  child: FloatingActionButton(
                    onPressed: _captureImage,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Result Overlay
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
                                  "Accuracy: ${_confidence!.toStringAsFixed(0)}%",
                                  style: const TextStyle(fontSize: 18),
                                ),
                              const SizedBox(height: 12),
                              if (_description != null)
                                Text(
                                  _description!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              const SizedBox(height: 20),

                              // Save Image Button
                              ElevatedButton(
                                onPressed: _saveToGallery,
                                child: const Text("Save Image to Gallery"),
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
