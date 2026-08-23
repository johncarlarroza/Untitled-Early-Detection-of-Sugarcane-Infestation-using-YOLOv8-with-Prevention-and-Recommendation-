import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class OffCamera extends StatefulWidget {
  const OffCamera({Key? key}) : super(key: key);

  @override
  State<OffCamera> createState() => _OffCameraState();
}

class _OffCameraState extends State<OffCamera> {
  CameraController? _cameraController;
  File? _image;

  String? _label;
  double? _confidence;

  String? _shortDesc;
  String? _details;
  String? _biology;
  String? _control;

  bool _isCameraInitialized = false;
  bool _isImageClassified = false;
  bool _isCapturing = false;

  int _selectedCameraIndex = 0;
  List<CameraDescription>? _cameras;

  FlashMode _flashMode = FlashMode.off;
  bool _isImagePickerActive = false;

  static const double _minConfidenceToAccept = 45.0;

  // zoom
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;

  // focus rectangle
  static const double focusWidth = 250;
  static const double focusHeight = 370;

  static const Map<String, Map<String, String>> _pestInfo = {
    "Cocoa Mealy Bugs": {
      "title": "Cocoa Mealybug",
      "category": "Sap-sucking insect pest",
      "risk": "Moderate",
      "desc":
          "White, wax-covered mealybugs or visible cotton-like colonies were detected on the cocoa plant.",
      "identify":
          "Look for actual small white insects covered with a powdery or waxy coating. They often appear in clusters on pods, stems, leaf joints, and young growth. Ant activity near the colony may also be present.",
      "damage":
          "Mealybugs suck plant sap, weaken young tissues, and may cause poor growth. Heavy colonies can produce honeydew and encourage sooty mold, while some mealybugs can also help spread plant diseases.",
      "mitigation":
          "Inspect nearby pods and stems, remove heavily infested plant material when practical, and reduce ant activity around affected trees because ants may protect mealybug colonies.",
      "recommendation":
          "Use good field sanitation and conserve natural enemies. For localized infestations, gentle washing or an appropriate horticultural/neem-based treatment may help. Use only locally registered crop-protection products and follow label directions.",
      "monitoring":
          "Recheck the affected tree and neighboring trees within several days. Pay special attention to hidden clusters around pod stalks, branch joints, and shaded areas.",
    },
    "Cocoa Mirid Bug": {
      "title": "Cocoa Mirid",
      "category": "Sap-sucking insect pest",
      "risk": "High",
      "desc":
          "A mirid-like insect or feeding damage associated with cocoa mirids was detected.",
      "identify":
          "Look for a bug-shaped body with long legs and antennae. Color may be orange, brown, or dark. Nearby pods or stems may show dark feeding punctures, spots, or sunken lesions.",
      "damage":
          "Mirids feed by piercing cocoa tissues. Repeated feeding can create dark lesions, damage young pods and shoots, and contribute to dieback when infestation is severe.",
      "mitigation":
          "Inspect the canopy and pods for additional insects and fresh lesions. Prune severely damaged or dead material, remove unnecessary dense growth, and keep the field clean to improve inspection and airflow.",
      "recommendation":
          "Use an integrated pest-management approach: regular monitoring, canopy management, sanitation, conservation of natural enemies, and only locally approved insecticides when infestation reaches a damaging level.",
      "monitoring":
          "Check during times when mirids are easier to observe and compare old dark lesions with fresh feeding marks. Monitor young pods and tender shoots closely.",
    },
    "Cocoa Pod Borrer": {
      "title": "Cocoa Pod Borer",
      "category": "Moth / internal pod pest",
      "risk": "High",
      "desc":
          "A cocoa pod borer moth or pod symptoms consistent with cocoa pod borer infestation were detected.",
      "identify":
          "Adult: small moth-like shape with narrow brown wings. Infested pod: look for entry or exit signs, abnormal or uneven ripening, and pods that may appear healthy outside while beans inside are damaged or difficult to separate.",
      "damage":
          "Larvae enter the pod and feed internally, damaging beans and surrounding tissues. This can reduce bean quality, make beans stick together, and cause serious harvest losses.",
      "mitigation":
          "Harvest ripe pods frequently, collect and properly dispose of infested pod material, and avoid leaving damaged pods in the field where the pest can continue its life cycle.",
      "recommendation":
          "Combine frequent harvesting, pruning, field sanitation, pod disposal, and monitoring. Where appropriate, pod sleeving or other locally recommended IPM measures can reduce infestation. Follow local agricultural guidance before using pesticides.",
      "monitoring":
          "Inspect developing pods regularly for uneven ripening and possible entry/exit signs. Open suspicious harvested pods to confirm internal bean damage.",
    },
    "Cocoa Phytophthopora": {
      "title": "Cocoa Phytophthora — Black Pod Disease",
      "category": "Fungal-like disease / black pod",
      "risk": "High",
      "desc":
          "Visible pod symptoms consistent with Phytophthora black pod disease were detected.",
      "identify":
          "Look for an expanding brown lesion on the cocoa pod that progressively becomes dark brown to black. The affected area usually enlarges instead of appearing as a small isolated spot and may eventually cover much of the pod.",
      "damage":
          "The infection can rot the pod and destroy the beans inside. In wet or humid conditions, disease can spread quickly between pods and infected plant material.",
      "mitigation":
          "Remove infected pods promptly and keep them away from healthy pods. Improve drainage, reduce excessive shade or dense canopy where appropriate, and remove infected debris to reduce sources of infection.",
      "recommendation":
          "Maintain good sanitation, regular harvesting, pruning, and airflow. During high-risk wet periods, follow local extension guidance for resistant planting material and any registered fungicide program suitable for cocoa.",
      "monitoring":
          "Inspect pods frequently after rain or during humid weather. Watch for new brown lesions that expand rapidly toward a dark or black rot.",
    },
    "Unclassified": {
      "title": "No Clear Pest or Disease Detected",
      "category": "Unclassified result",
      "risk": "No clear detection",
      "desc":
          "The image did not contain a sufficiently clear match for the cocoa pests or disease classes recognized by this model.",
      "identify":
          "This does not guarantee that the plant is pest- or disease-free. The target may be too small, blurred, poorly lit, hidden, or outside the classes supported by the model.",
      "damage": "No specific damage assessment can be made from this result.",
      "mitigation":
          "Take another close, well-lit photo and place the suspected insect, colony, lesion, or pod symptom inside the guide box. Avoid heavy blur and distracting backgrounds.",
      "recommendation":
          "Capture several angles. If unusual symptoms continue or spread, inspect the plant manually and consult a local agriculture or crop-protection specialist.",
      "monitoring":
          "Continue observing the pod, leaves, stems, and nearby trees for changes in color, lesions, insects, colonies, or abnormal ripening.",
    },
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

  String _normalizeLabel(String raw) {
    final cleaned = raw.toLowerCase().trim();

    // Text matching first makes this compatible with labels such as
    // "0 Cocoa_Mealybug" or "Cocoa Mealybug".
    if (cleaned.contains('mealy')) return 'Cocoa Mealy Bugs';
    if (cleaned.contains('mirid')) return 'Cocoa Mirid Bug';
    if (cleaned.contains('pod') &&
        (cleaned.contains('borer') || cleaned.contains('borrer'))) {
      return 'Cocoa Pod Borrer';
    }
    if (cleaned.contains('phytophthopora') ||
        cleaned.contains('phytophthora') ||
        cleaned.contains('phytoph') ||
        cleaned.contains('black pod') ||
        cleaned.contains('blackpod')) {
      return 'Cocoa Phytophthopora';
    }
    if (cleaned.contains('unclassified') ||
        cleaned.contains('unknown') ||
        cleaned.contains('no pest')) {
      return 'Unclassified';
    }

    // Fallback for a five-class Teachable Machine label order:
    // Actual labels.txt order: 0 Cocoa Mealy Bugs, 1 Cocoa Mirid Bug,
    // 2 Cocoa Pod Borrer, 3 Cocoa Phytophthopora, 4 Unclassified.
    if (cleaned.startsWith('0')) return 'Cocoa Mealy Bugs';
    if (cleaned.startsWith('1')) return 'Cocoa Mirid Bug';
    if (cleaned.startsWith('2')) return 'Cocoa Pod Borrer';
    if (cleaned.startsWith('3')) return 'Cocoa Phytophthopora';
    if (cleaned.startsWith('4')) return 'Unclassified';

    return 'Unclassified';
  }

  void _applyInfoToOverlay(String label) {
    final info = _pestInfo[label] ?? _pestInfo["Unclassified"]!;

    setState(() {
      _label = info["title"];
      _shortDesc = info["desc"];
      _details = info["identify"];
      _biology = info["damage"];
      _control = info["recommendation"];
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
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(_flashMode);

    _minZoom = await _cameraController!.getMinZoomLevel();
    _maxZoom = await _cameraController!.getMaxZoomLevel();
    _currentZoom = _currentZoom.clamp(_minZoom, _maxZoom);
    await _cameraController!.setZoomLevel(_currentZoom);

    if (!mounted) return;
    setState(() => _isCameraInitialized = true);
  }

  Future<File> _cropToFocusBox(File originalFile) async {
    final bytes = await originalFile.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return originalFile;

    final screenSize = MediaQuery.of(context).size;
    final previewSize = _cameraController!.value.previewSize!;

    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    double previewW = isPortrait ? previewSize.height : previewSize.width;
    double previewH = isPortrait ? previewSize.width : previewSize.height;

    final screenW = screenSize.width;
    final screenH = screenSize.height;

    final scale = math.max(screenW / previewW, screenH / previewH);
    final fittedW = previewW * scale;
    final fittedH = previewH * scale;

    final dx = (fittedW - screenW) / 2;
    final dy = (fittedH - screenH) / 2;

    final rectLeftOnScreen = (screenW - focusWidth) / 2;
    final rectTopOnScreen = (screenH - focusHeight) / 2;

    final previewLeft = rectLeftOnScreen + dx;
    final previewTop = rectTopOnScreen + dy;

    final sensorW = decoded.width.toDouble();
    final sensorH = decoded.height.toDouble();

    final scaleX = sensorW / fittedW;
    final scaleY = sensorH / fittedH;

    int cropX = (previewLeft * scaleX).round();
    int cropY = (previewTop * scaleY).round();
    int cropW = (focusWidth * scaleX).round();
    int cropH = (focusHeight * scaleY).round();

    cropX = cropX.clamp(0, decoded.width - 1);
    cropY = cropY.clamp(0, decoded.height - 1);
    cropW = cropW.clamp(1, decoded.width - cropX);
    cropH = cropH.clamp(1, decoded.height - cropY);

    final cropped = img.copyCrop(
      decoded,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );

    final croppedFile = File(
      '${originalFile.parent.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await croppedFile.writeAsBytes(img.encodeJpg(cropped, quality: 95));
    return croppedFile;
  }

  Future<void> _captureImage() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    try {
      setState(() => _isCapturing = true);

      final XFile file = await _cameraController!.takePicture();
      final original = File(file.path);

      final cropped = await _cropToFocusBox(original);

      setState(() {
        _image = cropped;
        _label = null;
        _confidence = null;
        _shortDesc = null;
        _details = null;
        _biology = null;
        _control = null;
        _isImageClassified = false;
      });

      await _classifyImage(_image!);
    } catch (e) {
      debugPrint("Capture error: $e");
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
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
        content: Text(success ? "Saved to Gallery!" : "Failed to save."),
      ),
    );
  }

  Future<void> _setZoom(double zoom) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final safeZoom = zoom.clamp(_minZoom, _maxZoom);
    await _cameraController!.setZoomLevel(safeZoom);

    if (!mounted) return;
    setState(() => _currentZoom = safeZoom);
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    _currentZoom = 1.0;
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
    return Scaffold(
      body: Stack(
        children: [
          _isCameraInitialized && _cameraController != null
              ? SizedBox.expand(child: CameraPreview(_cameraController!))
              : const Center(child: CircularProgressIndicator()),
          Center(
            child: Container(
              width: focusWidth,
              height: focusHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.greenAccent, width: 2),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
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
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_currentZoom.toStringAsFixed(1)}x",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            top: MediaQuery.of(context).size.height * 0.22,
            bottom: MediaQuery.of(context).size.height * 0.22,
            child: RotatedBox(
              quarterTurns: 3,
              child: SizedBox(
                width: 220,
                child: Slider(
                  min: _minZoom,
                  max: _maxZoom,
                  value: _currentZoom.clamp(_minZoom, _maxZoom),
                  onChanged: (v) => _setZoom(v),
                ),
              ),
            ),
          ),
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
                  onPressed: _isCapturing ? null : _captureImage,
                  backgroundColor: Colors.green,
                  child: _isCapturing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.camera, color: Colors.white),
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
                  ],
                ),
              ],
            ),
          ),
          if (_isImageClassified)
            _DetectionOverlay(
              image: _image,
              label: _label ?? "No Clear Pest or Disease Detected",
              confidence: _confidence,
              info: _pestInfo.entries
                  .firstWhere(
                    (entry) => entry.value["title"] == _label,
                    orElse: () => MapEntry(
                      "Unclassified",
                      _pestInfo["Unclassified"]!,
                    ),
                  )
                  .value,
              onClose: _reset,
              primaryButtonText: "Save Photo",
              primaryIcon: Icons.download_rounded,
              onPrimaryPressed: _saveImage,
            ),
        ],
      ),
    );
  }
}


class _DetectionOverlay extends StatelessWidget {
  final File? image;
  final String label;
  final double? confidence;
  final Map<String, String> info;
  final VoidCallback onClose;
  final String primaryButtonText;
  final IconData primaryIcon;
  final Future<void> Function() onPrimaryPressed;

  const _DetectionOverlay({
    required this.image,
    required this.label,
    required this.confidence,
    required this.info,
    required this.onClose,
    required this.primaryButtonText,
    required this.primaryIcon,
    required this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isUnclassified = info["risk"] == "No clear detection";
    final isDisease = (info["category"] ?? "").toLowerCase().contains("disease");
    final accent = const Color(0xFF079B83);

    final detectedText = isUnclassified
        ? "No Clear Detection"
        : isDisease
            ? "Disease Detected"
            : "Pest Detected";

    return Container(
      color: Colors.black.withOpacity(0.72),
      child: SafeArea(
        child: Center(
          child: Material(
            color: Colors.white,
            elevation: 18,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
                maxHeight: 780,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo header — simple, like a plant diagnosis article.
                          Stack(
                            children: [
                              image == null
                                  ? Container(
                                      height: 220,
                                      width: double.infinity,
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 52,
                                          color: Colors.black38,
                                        ),
                                      ),
                                    )
                                  : Image.file(
                                      image!,
                                      height: 220,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                              Positioned(
                                left: 10,
                                top: 10,
                                child: Material(
                                  color: Colors.black45,
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    onPressed: onClose,
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Detection banner.
                          Container(
                            width: double.infinity,
                            color: isUnclassified
                                ? Colors.blueGrey.shade600
                                : accent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isUnclassified
                                      ? Icons.search_off_rounded
                                      : isDisease
                                          ? Icons.eco_outlined
                                          : Icons.bug_report_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  detectedText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                if (confidence != null)
                                  Text(
                                    "${confidence!.toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isUnclassified
                                      ? "The image could not be clearly classified"
                                      : "We identified ${info["title"] ?? label} on Cocoa",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  info["title"] ?? label,
                                  style: TextStyle(
                                    fontSize: 24,
                                    height: 1.08,
                                    fontWeight: FontWeight.w800,
                                    color: isUnclassified
                                        ? Colors.blueGrey.shade700
                                        : accent,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      info["category"] ?? "Detection",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 3,
                                      height: 3,
                                      decoration: const BoxDecoration(
                                        color: Colors.black38,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Risk: ${info["risk"] ?? "Unknown"}",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                                const _ArticleHeading("Description"),
                                _ArticleText(info["desc"] ?? ""),

                                const _ArticleHeading("Mitigation"),
                                _ArticleBulletText(info["mitigation"] ?? ""),

                                const _ArticleHeading("How to Identify"),
                                _ArticleBulletText(info["identify"] ?? ""),

                                if (!isUnclassified) ...[
                                  const _ArticleHeading("Possible Damage"),
                                  _ArticleText(info["damage"] ?? ""),
                                ],

                                const _ArticleHeading("Management Recommendation"),
                                _ArticleBulletText(info["recommendation"] ?? ""),

                                const _ArticleHeading("Monitoring"),
                                _ArticleText(info["monitoring"] ?? ""),

                                const SizedBox(height: 6),
                                Divider(color: Colors.grey.shade300),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 17,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Text(
                                        "Use this result as a field guide. Confirm visible signs before applying any treatment.",
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          height: 1.4,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Simple action bar, kept outside the article content.
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onClose,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: accent,
                              side: const BorderSide(color: Color(0xFF079B83)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Scan Again",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => onPrimaryPressed(),
                            icon: Icon(primaryIcon, size: 18),
                            label: Text(primaryButtonText),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArticleHeading extends StatelessWidget {
  final String text;
  const _ArticleHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF222222),
        ),
      ),
    );
  }
}

class _ArticleText extends StatelessWidget {
  final String text;
  const _ArticleText(this.text);

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        height: 1.45,
        color: Colors.grey.shade800,
      ),
    );
  }
}

class _ArticleBulletText extends StatelessWidget {
  final String text;
  const _ArticleBulletText(this.text);

  List<String> _toPoints(String value) {
    // Keep the original pest information, but display it as short article bullets.
    final cleaned = value.replaceAll('\n', ' ').trim();
    if (cleaned.isEmpty) return const [];

    final sentenceRegex = RegExp(r'(?<=[.!?])\s+');
    final parts = cleaned
        .split(sentenceRegex)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return parts.isEmpty ? [cleaned] : parts;
  }

  @override
  Widget build(BuildContext context) {
    final points = _toPoints(text);
    if (points.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points
          .map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF555555),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.42,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
