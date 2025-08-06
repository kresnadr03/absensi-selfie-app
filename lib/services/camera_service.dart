import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CameraService {
  static Future<File?> takeSelfie(BuildContext context) async {
    // Ambil list kamera
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    // Navigasi ke layar kamera
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraCaptureScreen(camera: frontCamera),
      ),
    );

    return result is File ? result : null;
  }
}

class CameraCaptureScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraCaptureScreen({super.key, required this.camera});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  late CameraController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() => _isReady = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture(BuildContext buildContext) async {
    if (!_controller.value.isInitialized) return;
    if (_controller.value.isTakingPicture) return;

    try {
      final image = await _controller.takePicture();
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = join(tempDir.path, fileName);
      final savedFile = await File(image.path).copy(savedPath);

      if (!mounted) return;
      Navigator.pop(buildContext, savedFile);
    } catch (e) {
      debugPrint('Error saat ambil foto: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(buildContext).showSnackBar(
        SnackBar(content: Text('Gagal ambil foto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    if (!_isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ambil Selfie')),
      body: CameraPreview(_controller),
      floatingActionButton: FloatingActionButton(
        onPressed: _isReady ? () => _takePicture(buildContext) : null,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
