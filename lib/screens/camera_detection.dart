import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class CameraDetectionScreen extends StatefulWidget {
  @override
  _CameraDetectionScreenState createState() => _CameraDetectionScreenState();
}

class _CameraDetectionScreenState extends State<CameraDetectionScreen> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  late Interpreter _interpreter;
  late StreamController<List<dynamic>> _streamController;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
    _streamController = StreamController<List<dynamic>>();
  }

  @override
  void dispose() {
    _controller.dispose();
    _streamController.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('your_model.tflite');
  }

  Future<void> _runModelOnFrame(CameraImage img) async {
    if (!_isDetecting) {
      _isDetecting = true;
      final input = img.planes.map((plane) {
        return plane.bytes;
      }).toList();

      final imgSize = Size(img.width.toDouble(), img.height.toDouble());
      final List<dynamic> results = await _interpreter.run(input, imgSize);

      _streamController.add(results);

      _isDetecting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Camera Detection'),
          actions: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Navigate to home screen
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            CameraPreview(_controller),
            StreamBuilder<List<dynamic>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Display classification results
                  return Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.black54,
                      child: Text(
                        snapshot.data!.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try {
              await _controller.startImageStream(_runModelOnFrame);
            } catch (e) {
              print(e);
            }
          },
          child: Icon(Icons.camera),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
