import 'dart:io';
import 'dart:typed_data';
import 'package:wildwatch_take4/result.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isScanSelected = true;
  late File _image;
  dynamic _probability = 0;
  String? _result;
  List<String>? _labels;
  late tfl.Interpreter _interpreter;
  final picker = ImagePicker();

  // CameraController fields
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture; // Changed to nullable type
  bool isFlashOn = false; // New state to track flash mode

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    loadModel().then((_) {
      loadLabels().then((loadedLabels) {
        setState(() {
          _labels = loadedLabels;
        });
      });
    });
  }

  void _disposeCamera() {
    if (_cameraController.value.isInitialized) {
      _cameraController.dispose();
    }
  }

  void _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          imageFormatGroup: ImageFormatGroup.yuv420, // Adjust format if needed
        );
        _initializeControllerFuture = _cameraController.initialize();
        await _initializeControllerFuture;

        // Set the flash mode to off initially
        await _cameraController.setFlashMode(FlashMode.off);

        setState(() {}); // Rebuild UI when the camera is ready
      } else {
        debugPrint('No cameras available');
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // Top AppBar Section
              Container(
                height: 100, // Increase height for better vertical centering
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              // Scan & Upload Toggle Buttons
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    // Scan Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isScanSelected = true;
                          });
                          _initializeCamera(); // Re-initialize the camera when switching to scan
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: isScanSelected
                                ? const Color(0xFFCDEB45)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              'Scan',
                              style: TextStyle(
                                fontFamily: 'Minecraft',
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Upload Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isScanSelected = false;
                          });
                          _disposeCamera(); // Dispose of the camera when switching to upload
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: isScanSelected
                                ? Colors.transparent
                                : const Color(0xFFCDEB45),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              'Upload',
                              style: TextStyle(
                                fontFamily: 'Minecraft',
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: isScanSelected ? _buildScanView() : _buildUploadView(),
              ),
            ],
          ),
          // Conditionally render flash icon and scan button
          if (isScanSelected)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Row(
                  children: [
                    // Flash Icon with White Background
                    GestureDetector(
                      onTap: _toggleFlash, // Toggle flash on tap
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            isFlashOn ? Icons.flashlight_off : Icons.flashlight_on, // Change icon based on state
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Scan Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            // Ensure the camera is initialized
                            await _initializeControllerFuture;
                            final image = await _cameraController.takePicture();
                            _setImage(File(image.path));
                          } catch (e) {
                            debugPrint('Error capturing image: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCDEB45),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Scan',
                          style: TextStyle(
                            fontFamily: 'Minecraft',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Scan & Upload Text
          const Positioned(
            top: 40,
            left: 80,
            right: 80,
            child: Center(
              child: Text(
                'Scan & Upload',
                style: TextStyle(
                  fontFamily: 'Minecraft',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildScanView() {
    if (_initializeControllerFuture == null) {
      // Fallback UI if the initialization hasn't started
      return Center(child: Text('Initializing camera...'));
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Display the camera preview with overlay
          return Stack(
            children: [
              CameraPreview(_cameraController), // Camera feed
              // Overlaying the frame
              Positioned(
                top: MediaQuery.of(context).size.height *
                    0.15, // Moved the frame slightly more upward
                left: MediaQuery.of(context).size.width *
                    0.175, // Adjust this value to center horizontally
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: MediaQuery.of(context).size.width * 0.65,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        width: 2), // Frame border color
                    borderRadius: BorderRadius.circular(
                        16), // Adjust for rounded corners if needed
                  ),
                ),
              ),
              // Text positioned relative to the frame
              const Positioned(
                bottom: 140, // Adjust this value to move the text
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Please hold still while the camera is calibrating',
                    style: TextStyle(
                      fontFamily: 'Minecraft', // Your preferred font
                      fontSize: 16,
                      color: Colors.pinkAccent, // Adjust color as needed
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          // Handle error scenario
          return Center(
              child: Text('Error initializing camera: ${snapshot.error}'));
        } else {
          // Display a loading indicator until the camera is initialized
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _toggleFlash() async {
    try {
      if (_cameraController.value.flashMode == FlashMode.off) {
        await _cameraController.setFlashMode(FlashMode.torch); // Turn on torch
        setState(() {
          isFlashOn = true;
        });
      } else {
        await _cameraController.setFlashMode(FlashMode.off); // Turn off torch
        setState(() {
          isFlashOn = false;
        });
      }
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Widget _buildUploadView() {
  // Keep the original upload view with updated alignment for buttons
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: pickImageFromGallery, // Allow image selection when the plus icon is tapped
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 50,
                  color: Colors.blueGrey,
                ),
                SizedBox(height: 8),
                Text(
                  'Upload a Picture',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 4),
                Text(
                  'You can upload an image by importing or scanning with your camera',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20), // Adjust spacing to align with the box on top
        // Aligning buttons with the container above
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: pickImageFromGallery,
                icon: const Icon(Icons.photo, size: 35),
                label: const Text(
                  'Gallery',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size.zero, // Ensures button doesn't have a minimum size constraint
                ),
              ),
            ),
            const SizedBox(width: 16), // Spacing between buttons
            Expanded(
              child: ElevatedButton.icon(
                onPressed: pickImageFromCamera,
                icon: const Icon(Icons.camera_alt, size: 35),
                label: const Text(
                  'Camera',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size.zero, // Ensures button doesn't have a minimum size constraint
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 6, // Replace with your image count
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/placeholder_image.png'),
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


  Future<void> loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset('assets/model_unquant.tflite');
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _setImage(File(pickedFile.path));
    }
  }

  Future<void> pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _setImage(File(pickedFile.path));
    }
  }

  void _setImage(File image) {
    setState(() {
      _image = image;
    });
    runInference();
  }

  Future<Uint8List> preprocessImage(File imageFile) async {
  img.Image? originalImage = img.decodeImage(await imageFile.readAsBytes());
  img.Image resizedImage = img.copyResize(originalImage!, width: 224, height: 224);

  // Convert pixels to Float32 and normalize
  List<double> normalizedPixels = resizedImage
      .getBytes()
      .map((pixel) => pixel / 255.0) // Normalize to 0.0 - 1.0
      .toList();

  return Float32List.fromList(normalizedPixels).buffer.asUint8List();
}

  Future<void> runInference() async {
  if (_labels == null) {
    return;
  }
  try {
    Uint8List inputBytes = await preprocessImage(_image);
    var input = inputBytes.buffer.asFloat32List().reshape([1, 224, 224, 3]);

    // Adjust output buffer for float32
    var outputBuffer = List<double>.filled(26, 0).reshape([1, 26]);

    _interpreter.run(input, outputBuffer);
    List<double> output = outputBuffer[0];
    debugPrint('Raw output: $output');

    // Find the highest score
    double maxScore = output.reduce(max);
    int highestProbIndex = output.indexOf(maxScore);

    // Set a confidence threshold
    const double confidenceThreshold = 0.6; // Adjust this based on your model's accuracy
    if (maxScore < confidenceThreshold) {
      setState(() {
        _result = "Unidentified";
        _probability = maxScore;
      });
    } else {
      String classificationResult = _labels![highestProbIndex];
      setState(() {
        _result = classificationResult;
        _probability = maxScore;
      });
    }

    navigateToResult();
  } catch (e) {
    debugPrint('Error during inference: $e');
  }
}


  Future<List<String>> loadLabels() async {
    final labelsData =
        await DefaultAssetBundle.of(context).loadString('assets/labels2.txt');
    return labelsData.split('\n');
  }

  void navigateToResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          image: _image,
          result: _result!,
          probability: _probability,
        ),
      ),
    );
  }
}
