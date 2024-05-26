import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool isInitialized = false;
  Interpreter? _interpreter;
  bool isDetecting = false;
  List<dynamic>? _recognitions;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high);
    await _controller?.initialize();
    setState(() {
      isInitialized = true;
    });
    _controller?.startImageStream((CameraImage img) {
      if (!isDetecting) {
        isDetecting = true;
        _runModelOnFrame(img).then((recognitions) {
          setState(() {
            _recognitions = recognitions;
          });
          isDetecting = false;
        });
      }
    });
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('your_model.tflite');
  }

  Future<List<dynamic>> _runModelOnFrame(CameraImage img) async {
    var input = img.planes[0].bytes; // You might need to preprocess this
    // Assuming input is already in the correct format for your model
    var output =
        List.filled(1001, 0).reshape([1, 1001]); // Adjust based on your model
    _interpreter!.run(input, output);
    return output;
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Camera')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          _buildResults(),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return _recognitions != null
        ? Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              height: 100,
              child: ListView.builder(
                itemCount: _recognitions?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      '${_recognitions![index]["label"]} ${(100 * _recognitions![index]["confidence"]).toStringAsFixed(0)}%',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          )
        : Container();
  }
}
