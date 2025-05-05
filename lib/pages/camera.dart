import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  final Function(File) onImageCaptured;

  const CameraPage({required this.onImageCaptured, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      print("Izin kamera tidak diberikan");
      Navigator.pop(context);
      return;
    }

    try {
      final cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      await _controller.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      print("Gagal inisialisasi kamera: $e");
      Navigator.pop(context);
    }
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized || _controller.value.isTakingPicture) return;

    try {
      final XFile file = await _controller.takePicture();
      widget.onImageCaptured(File(file.path));
      Navigator.pop(context);
    } catch (e) {
      print("Gagal ambil foto: $e");
    }
  }

  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _controller.dispose();
    }
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
          CameraPreview(_controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: _takePicture,
                child: Icon(Icons.camera),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
