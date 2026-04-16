import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'pose_painter.dart'; // File pelukis yang kita buat tadi

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const RunformApp());
}

class RunformApp extends StatelessWidget {
  const RunformApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  static const platform = MethodChannel('com.runform.ai/predict');
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  
  String statusLari = "INITIALIZING...";
  bool isProcessing = false;
  CustomPaint? customPaint; // Variabel untuk menampung gambar skeleton

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      controller = CameraController(
        _cameras[0],
        ResolutionPreset.low, 
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      try {
        await controller!.initialize();
        controller!.startImageStream((CameraImage image) {
          if (isProcessing) return;
          setState(() { isProcessing = true; });
          _processCameraImage(image);
        });
        if (!mounted) return;
        setState(() {});
      } catch (e) {
        debugPrint("Init Error: $e");
      }
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      isProcessing = false;
      return;
    }

    try {
      final poses = await _poseDetector.processImage(inputImage);
      
      if (poses.isNotEmpty) {
        final pose = poses.first;

        // 1. SIAPKAN VISUALISASI SKELETON
        final painter = PosePainter(
          pose, 
          Size(image.width.toDouble(), image.height.toDouble()), 
          InputImageRotation.rotation90deg 
        );

        // 2. EKSTRAKSI FITUR UNTUK JAVA (133 Fitur)
        List<double> features = [];
        for (var landmark in pose.landmarks.values) {
          features.add(landmark.x);
          features.add(landmark.y);
          features.add(landmark.z);
          features.add(landmark.likelihood);
        }
        while (features.length < 133) { features.add(0.0); }

        // 3. PREDIKSI NATIVE
        final int result = await platform.invokeMethod('getPrediction', {"features": features});
        
        if (mounted) {
          setState(() {
            customPaint = CustomPaint(painter: painter);
            statusLari = result == 0 ? "OVERSTRIDE" : "NORMAL";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            statusLari = "MENCARI SUBJEK...";
            customPaint = null;
          });
        }
      }
    } catch (e) {
      debugPrint("AI Error: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 100)); 
      isProcessing = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      final plane = image.planes.first;
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation90deg,
          format: InputImageFormat.nv21,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) { return null; }
  }

  @override
  void dispose() {
    _poseDetector.close();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Kamera
          ClipRRect(
            child: CameraPreview(controller!),
          ),
          
          // Layer Skeleton (Garis sendi)
          if (customPaint != null) customPaint!,

          // Overlay Dekorasi Frame (Agar kelihatan seperti alat medis/scanning)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white10, width: 20),
            ),
          ),

          // Header Panel
          Positioned(
            top: 60,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("RUNFORM-AI v1.0", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                Text("BETA ANALYSIS MODE", style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ),

          // Bottom Status Panel
          Positioned(
            bottom: 40,
            left: 25,
            right: 25,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
                boxShadow: [BoxShadow(color: _getStatusColor().withOpacity(0.4), blurRadius: 20)],
              ),
              child: Column(
                children: [
                  Text(
                    "BIOMECHANIC STATUS",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white.withOpacity(0.8), letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 5),
                  Text(
  statusLari,
  style: const TextStyle(
    fontSize: 32, 
    fontWeight: FontWeight.w900, // <--- Ganti di sini
    color: Colors.white
  ),
),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (statusLari == "NORMAL") return Colors.green;
    if (statusLari == "OVERSTRIDE") return Colors.redAccent;
    return Colors.blueGrey;
  }
}