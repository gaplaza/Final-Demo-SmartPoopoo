import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class ImageDetectionScreen extends StatefulWidget {
  const ImageDetectionScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _ImageDetectionScreenState createState() => _ImageDetectionScreenState();
}

class _ImageDetectionScreenState extends State<ImageDetectionScreen> {
  late CameraController controller;
  bool isBusy = false;
  dynamic objectDetector;
  late Size size;
  late Future<void> _initializeCameraFuture; // 카메라 초기화 상태를 추적하는 Future
  late List<CameraDescription> cameras; // 카메라 리스트

  @override
  void initState() {
    super.initState();
    _initializeCameraFuture = initializeCameras(); // 카메라 초기화 Future 설정
  }

  // 카메라 리스트를 가져오고 초기화하는 메서드
  Future<void> initializeCameras() async {
    // 카메라 리스트를 가져옴
    cameras = await availableCameras();

    if (cameras.isEmpty) {
      print("No cameras found!");
      return; // 카메라가 없을 경우 초기화하지 않음
    }

    loadModel();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller.initialize();
    controller.startImageStream((image) {
      if (!isBusy) {
        isBusy = true;
        img = image;
        doObjectDetectionOnFrame();
      }
    });
  }

  Future<void> loadModel() async {
    final modelPath =
        await getModelPath('assets/ml/model_unquant_metadata.tflite');
    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.stream,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
    );
    objectDetector = ObjectDetector(options: options);
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }
    return file.path;
  }

  @override
  void dispose() {
    controller.dispose();
    objectDetector.close();
    super.dispose();
  }

  // TODO: object detection on a frame
  dynamic _scanResults;
  CameraImage? img;

  doObjectDetectionOnFrame() async {
    var frameImg = _inputImageFromCameraImage(img!);
    List<DetectedObject> objects = await objectDetector.processImage(frameImg);
    print("len= ${objects.length}");

    if (mounted) {
      setState(() {
        _scanResults = objects;
        isBusy = false;
      });
    }
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = cameras[0];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // Show rectangles around detected objects
  Widget buildResult() {
    if (_scanResults == null || !controller.value.isInitialized) {
      return const Text('');
    }

    final Size imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    CustomPainter painter = ObjectDetectorPainter(imageSize, _scanResults);
    return CustomPaint(painter: painter);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return PopScope<void>(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, void result) {
          if (didPop) {
            Navigator.of(context).maybePop(); // main.dart로 이동
          }
          return;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Object detector"),
            backgroundColor: Colors.blue,
          ),
          backgroundColor: Colors.black,
          body: FutureBuilder<void>(
            future: _initializeCameraFuture, // 카메라 초기화 Future를 전달
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 카메라 초기화 완료 후 화면 렌더링
                return Stack(
                  children: [
                    Positioned(
                      top: 0.0,
                      left: 0.0,
                      width: size.width,
                      height: size.height,
                      child: (controller.value.isInitialized)
                          ? AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: CameraPreview(controller),
                            )
                          : Container(),
                    ),
                    Positioned(
                      top: 0.0,
                      left: 0.0,
                      width: size.width,
                      height: size.height,
                      child: buildResult(),
                    ),
                  ],
                );
              } else {
                // 카메라 초기화 중 로딩 인디케이터 표시
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ));
  }
}

class ObjectDetectorPainter extends CustomPainter {
  ObjectDetectorPainter(this.absoluteImageSize, this.objects);

  final Size absoluteImageSize;
  final List<DetectedObject> objects;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.pinkAccent;

    for (DetectedObject detectedObject in objects) {
      canvas.drawRect(
        Rect.fromLTRB(
          detectedObject.boundingBox.left * scaleX,
          detectedObject.boundingBox.top * scaleY,
          detectedObject.boundingBox.right * scaleX,
          detectedObject.boundingBox.bottom * scaleY,
        ),
        paint,
      );

      for (Label label in detectedObject.labels) {
        print("${label.text}   ${label.confidence.toStringAsFixed(2)}");
        TextSpan span = TextSpan(
          text: label.text,
          style: const TextStyle(fontSize: 25, color: Colors.blue),
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(detectedObject.boundingBox.left * scaleX,
              detectedObject.boundingBox.top * scaleY),
        );
        break;
      }
    }
  }

  @override
  bool shouldRepaint(ObjectDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.objects != objects;
  }
}
