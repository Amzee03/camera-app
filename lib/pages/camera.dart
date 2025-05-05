import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  final Function(File) onImageCaptured;

  const CameraPage({required this.onImageCaptured, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  XFile? _previewImage;

  bool get _isInitialized => _controller?.value.isInitialized ?? false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final start = DateTime.now();
    print("🟡 Mulai request permission: $start");

    if (!kIsWeb) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        print("❌ Kamera tidak diizinkan");
        Navigator.pop(context);
        return;
      }
    }

    try {
      print("🟡 Request daftar kamera...");
      _cameras = await availableCameras();
      print("✅ Dapat kamera (${_cameras.length}) pada ${DateTime.now()}");
      _startCamera(_selectedCameraIndex);
    } catch (e) {
      print("❌ Gagal mendapatkan kamera: $e");
      Navigator.pop(context);
    }
  }


  void _startCamera(int cameraIndex) async {
    final startInit = DateTime.now();
    print("⚙️ Mulai inisialisasi kamera index $cameraIndex: $startInit");

    await _controller?.dispose();
    _controller = CameraController(_cameras[cameraIndex], ResolutionPreset.medium);

    try {
      await _controller!.initialize();
      if (!mounted) return;

      final endInit = DateTime.now();
      print("✅ Kamera siap: $endInit (waktu inisialisasi: ${endInit.difference(startInit).inMilliseconds} ms)");

      setState(() {
        _previewImage = null;
      });
    } catch (e) {
      print("❌ Gagal inisialisasi kamera: $e");
    }
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _startCamera(_selectedCameraIndex);
  }

  Future<void> _takePicture() async {
    if (!_isInitialized || _controller!.value.isTakingPicture) return;

    try {
      final XFile file = await _controller!.takePicture();
      setState(() {
        _previewImage = file;
      });
    } catch (e) {
      print("Gagal mengambil foto: $e");
    }
  }

  void _sendImage() {
    if (_previewImage != null) {
      widget.onImageCaptured(File(_previewImage!.path));
      Navigator.pop(context);
    }
  }

  void _cancelPreview() {
    setState(() {
      _previewImage = null;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          if (_previewImage == null)
            Positioned.fill(child: CameraPreview(_controller!))
          else
            Positioned.fill(
              child: Image.file(
                File(_previewImage!.path),
                fit: BoxFit.cover,
              ),
            ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (_previewImage == null) ...[
            Positioned(
              bottom: 30,
              left: 30,
              child: FloatingActionButton(
                heroTag: "switch",
                backgroundColor: Colors.grey.shade700,
                onPressed: _switchCamera,
                child: Icon(Icons.switch_camera),
              ),
            ),
            Positioned(
              bottom: 30,
              right: 30,
              child: FloatingActionButton(
                heroTag: "capture",
                backgroundColor: Colors.green,
                onPressed: _takePicture,
                child: Icon(Icons.camera),
              ),
            ),
          ] else ...[
            Positioned(
              bottom: 30,
              left: 30,
              child: FloatingActionButton(
                heroTag: "cancel",
                backgroundColor: Colors.red,
                onPressed: _cancelPreview,
                child: Icon(Icons.close),
              ),
            ),
            Positioned(
              bottom: 30,
              right: 30,
              child: FloatingActionButton(
                heroTag: "send",
                backgroundColor: Colors.green,
                onPressed: _sendImage,
                child: Icon(Icons.send),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
