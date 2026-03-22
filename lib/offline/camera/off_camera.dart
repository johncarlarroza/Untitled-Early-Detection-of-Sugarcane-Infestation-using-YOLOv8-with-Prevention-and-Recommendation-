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
  double? _confidence; // 0-100

  // Overlay text sections
  String? _shortDesc;
  String? _details;
  String? _biology;
  String? _control;

  bool _isCameraInitialized = false;
  bool _isImageClassified = false;

  int _selectedCameraIndex = 0;
  List<CameraDescription>? _cameras;

  FlashMode _flashMode = FlashMode.off;
  bool _isImagePickerActive = false;

  static const double _minConfidenceToAccept = 45.0;

  // ✅ Your content (exactly as you wrote)
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

  // Match your labels.txt (0..3) and normalize to one of:
  // Cocoa Mealy Bugs / Cocoa Mirid Bug / Cocoa Pod Borrer / Unclassified
  String _normalizeLabel(String raw) {
    final cleaned = raw.toLowerCase().trim();

    if (cleaned.startsWith('0')) return 'Cocoa Mealy Bugs';
    if (cleaned.startsWith('1')) return 'Cocoa Mirid Bug';
    if (cleaned.startsWith('2')) return 'Cocoa Pod Borrer';
    if (cleaned.startsWith('3')) return 'Unclassified';

    // fallback if number not included
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

  void _applyInfoToOverlay(String label) {
    final info = _pestInfo[label] ?? _pestInfo["Unclassified"]!;

    setState(() {
      // Title shown at top
      _label = info["title"];

      // Sections
      _shortDesc = info["desc"];
      _details = info["details"];
      _biology = info["biology"];
      _control = info["control"];
    });
  }

  Future<void> _classifyImage(File image) async {
    final recognition = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      threshold: 0.2,
      numResults: 3,
      asynch: true,
    );

    if (recognition == null || recognition.isEmpty) {
      setState(() {
        _confidence = null;
        _isImageClassified = true;
      });
      _applyInfoToOverlay("Unclassified");
      return;
    }

    final rawLabel = (recognition[0]['label'] ?? '').toString();
    final conf01 = (recognition[0]['confidence'] ?? 0.0) as double;
    final conf = conf01 * 100;

    final normalized = _normalizeLabel(rawLabel);

    // If model says Unclassified or confidence too low, show Unclassified
    final finalLabel =
        (normalized == "Unclassified" || conf < _minConfidenceToAccept)
            ? "Unclassified"
            : normalized;

    setState(() {
      _confidence = conf;
      _isImageClassified = true;
    });

    _applyInfoToOverlay(finalLabel);
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    await _cameraController?.dispose();

    _cameraController = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(_flashMode);

    if (!mounted) return;
    setState(() => _isCameraInitialized = true);
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final XFile file = await _cameraController!.takePicture();

    setState(() {
      _image = File(file.path);
      _label = null;
      _confidence = null;
      _shortDesc = null;
      _details = null;
      _biology = null;
      _control = null;
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
      _shortDesc = null;
      _details = null;
      _biology = null;
      _control = null;
      _isImageClassified = false;
    });

    await _classifyImage(_image!);
  }

  Future<void> _saveImage() async {
    if (_image == null) return;

    final Uint8List bytes = await _image!.readAsBytes();
    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: "pestcoa_${DateTime.now().millisecondsSinceEpoch}",
    );

    final bool success = result["isSuccess"] == true;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(success ? "Saved to Gallery!" : "Failed to save.")),
    );
  }

  void _switchCamera() async {
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
    _cameraController!.setFlashMode(_flashMode);
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Snap Tips"),
        content: Image.asset('assets/tips.png'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      _isImageClassified = false;
      _image = null;
      _label = null;
      _confidence = null;
      _shortDesc = null;
      _details = null;
      _biology = null;
      _control = null;
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
    const double focusWidth = 250;
    const double focusHeight = 370;

    return Scaffold(
      body: Stack(
        children: [
          _isCameraInitialized && _cameraController != null
              ? SizedBox.expand(child: CameraPreview(_cameraController!))
              : const Center(child: CircularProgressIndicator()),

          // Focus box
          Center(
            child: Container(
              width: focusWidth,
              height: focusHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.greenAccent, width: 1.2),
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

          // Bottom capture buttons
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
                    // const Text("Snap Tips",
                    //     style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),

          // ✅ Classification Overlay (shows your full text)
          if (_isImageClassified)
            GestureDetector(
              onTap: _reset,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    elevation: 10,
                    child: SizedBox(
                      width: 360,
                      height: 560,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Image preview
                            if (_image != null)
                              Container(
                                height: 240,
                                width: 240,
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
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (_confidence != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  "Confidence: ${_confidence!.toStringAsFixed(0)}%",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),

                            const SizedBox(height: 12),

                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Section(
                                      title: "Description",
                                      text: _shortDesc ?? "",
                                    ),
                                    _Section(
                                      title: "Detailed Information",
                                      text: _details ?? "",
                                    ),
                                    _Section(
                                      title: "Biology and Behavior",
                                      text: _biology ?? "",
                                    ),
                                    _Section(
                                      title: "Control Measures",
                                      text: _control ?? "",
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _reset,
                                    child: const Text("Close"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _saveImage,
                                    child: const Text("Save to Gallery"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Tap outside to close",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
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

class _Section extends StatelessWidget {
  final String title;
  final String text;

  const _Section({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
