import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTFModel();
    _initializeCamera();
  }

  Future<void> _loadTFModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> _classifyImage(File image) async {
    var recognition = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      threshold: 0.2,
      numResults: 2,
      asynch: true,
    );

    if (recognition == null || recognition.isEmpty) {
      setState(() {
        _label = "Unclassified";
        _confidence = null;
        _description = "Unable to classify this pest. Please try again.";
        _isImageClassified = true;
      });
      return;
    }

    String detected = recognition[0]['label'];
    double conf = recognition[0]['confidence'] * 100;

    setState(() {
      _label = detected;
      _confidence = conf;
      _description = _getDescription(detected);
      _isImageClassified = true;
    });
  }

  String _getDescription(String? label) {
    switch (label) {
      case "pest":
        return "A destructive pest known for drilling into sugarcane.";
      case "pest":
        return "Feeds on leaf tissues anqd damages young sugarcane leaves.";
      case "pt":
        return "A sap-sucking pest that weakens sugarcanes.";
      default:
        return "Unclassified pest.";
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(_flashMode);

    setState(() => _isCameraInitialized = true);
  }

  Future<void> _captureImage() async {
    if (!_cameraController!.value.isInitialized) return;

    XFile file = await _cameraController!.takePicture();

    setState(() {
      _image = File(file.path);
      _label = null;
      _confidence = null;
      _description = null;
      _isImageClassified = false;
    });

    await _classifyImage(_image!);
  }

  Future<void> _pickFromGallery() async {
    if (_isImagePickerActive) return;

    setState(() => _isImagePickerActive = true);

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    setState(() => _isImagePickerActive = false);

    if (file == null) return;

    setState(() {
      _image = File(file.path);
      _label = null;
      _confidence = null;
      _description = null;
      _isImageClassified = false;
    });

    await _classifyImage(_image!);
  }

  Future<void> _saveImage() async {
    if (_image == null) return;

    Uint8List bytes = await _image!.readAsBytes();

    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: "pest_image_${DateTime.now().millisecondsSinceEpoch}",
    );

    final bool success = result["isSuccess"] == true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Saved to Gallery!" : "Failed to save."),
      ),
    );
  }

  void _switchCamera() async {
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    await _initializeCamera();
  }

  void _toggleFlash() {
    setState(() {
      _flashMode =
          _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    });

    _cameraController!.setFlashMode(_flashMode);
  }

  void _reset() {
    setState(() {
      _isImageClassified = false;
      _image = null;
      _label = null;
      _confidence = null;
      _description = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double focusWidth = 250;
    double focusHeight = 400;

    return Scaffold(
      body: Stack(
        children: [
          _isCameraInitialized
              ? SizedBox.expand(child: CameraPreview(_cameraController!))
              : const Center(child: CircularProgressIndicator()),

          /// Focus box
          Center(
            child: Container(
              width: focusWidth,
              height: focusHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 2),
              ),
            ),
          ),

          /// Flash + Switch camera
          Positioned(
            top: 40,
            left: 16,
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleFlash,
                  icon: Icon(
                    _flashMode == FlashMode.torch
                        ? Icons.flash_on
                        : Icons.flash_off,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _switchCamera,
                  icon: const Icon(Icons.switch_camera, color: Colors.white),
                ),
              ],
            ),
          ),

          /// Bottom capture buttons
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton(
                  onPressed: _pickFromGallery,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.photo, color: Colors.black),
                ),
                FloatingActionButton(
                  onPressed: _captureImage,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.camera, color: Colors.white),
                ),
              ],
            ),
          ),

          /// Classification Popup
          if (_isImageClassified)
            GestureDetector(
              onTap: _reset,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    elevation: 10,
                    child: SizedBox(
                      width: 350,
                      height: 500,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            /// Image preview
                            Container(
                              height: 260,
                              width: 260,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(_image!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Text(
                              _label ?? "",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (_confidence != null)
                              Text(
                                "Accuracy: ${_confidence!.toStringAsFixed(0)}%",
                                style: const TextStyle(fontSize: 16),
                              ),

                            const SizedBox(height: 10),

                            Text(
                              _description ?? "",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 20),

                            ElevatedButton(
                              onPressed: _saveImage,
                              child: const Text("Save to Gallery"),
                            ),
                          ],
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
