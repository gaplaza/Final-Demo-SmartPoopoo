import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class FrameDetectionScreen extends StatefulWidget {
  FrameDetectionScreen({Key? key}) : super(key: key);
  @override
  _FrameDetectionScreenState createState() => _FrameDetectionScreenState();
}

class _FrameDetectionScreenState extends State<FrameDetectionScreen> {
  late ImagePicker imagePicker;
  File? _image;
  var image;
  //TODO declare detector
  late ObjectDetector objectDetector;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    //TODO initialize detector
    // final options = ObjectDetectorOptions(mode: DetectionMode.single, classifyObjects: true, multipleObjects: true);
    // final objectDetector = ObjectDetector(options: options);
    loadModel();
  }

  loadModel() async {
    final modelPath =
        await getModelPath('assets/ml/model_unquant_metadata.tflite');
    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.single,
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
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  @override
  void dispose() {
    objectDetector.close();
    super.dispose();
  }

  //TODO capture image using camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doObjectDetection();
    }
  }

  //TODO choose image using gallery
  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doObjectDetection();
    }
  }

  //TODO face detection code here
  List<DetectedObject> objects = [];
  doObjectDetection() async {
    if (_image == null) {
      print("No image selected.");
      return; // 이미지가 없으면 작업을 중단
    }
    InputImage inputImage = InputImage.fromFile(_image!);
    objects = await objectDetector.processImage(inputImage);

    for (DetectedObject detectedObject in objects) {
      print("Detected object at ${detectedObject.boundingBox}");
      final rect = detectedObject.boundingBox;
      final trackingId = detectedObject.trackingId;

      for (Label label in detectedObject.labels) {
        print('${label.text} ${label.confidence}');
      }
    }
    setState(() {
      _image;
    });
    drawRectanglesAroundObjects();
  }

  // //TODO draw rectangles
  drawRectanglesAroundObjects() async {
    if (_image == null) {
      print("No image available to draw.");
      return; // 이미지가 없으면 작업을 중단
    }
    Uint8List imageData = await _image!.readAsBytes();
    ui.Image decodedImage = await decodeImageFromList(imageData);

    setState(() {
      image = decodedImage; // 디코딩된 이미지를 저장
      objects;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop(); // 이전 화면으로 이동
              },
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/bg.jpg'), fit: BoxFit.cover),
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 100,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: Stack(children: <Widget>[
                    Center(
                      child: ElevatedButton(
                        onPressed: _imgFromGallery,
                        onLongPress: _imgFromCamera,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent),
                        child:
                            // Container(
                            //   margin: const EdgeInsets.only(top: 8),
                            //   child: _image != null
                            //       ? Image.file(
                            //     _image!,
                            //     width: 350,
                            //     height: 350,
                            //     fit: BoxFit.fill,
                            //   )
                            //       : Container(
                            //     width: 350,
                            //     height: 350,
                            //     color: Colors.pinkAccent,
                            //     child: const Icon(
                            //       Icons.camera_alt,
                            //       color: Colors.black,
                            //       size: 100,
                            //     ),
                            //   ),
                            // ),
                            Container(
                          width: 350,
                          height: 350,
                          margin: const EdgeInsets.only(
                            top: 45,
                          ),
                          child: image != null
                              ? Center(
                                  child: FittedBox(
                                    child: SizedBox(
                                      width: image.width.toDouble(),
                                      height: image.height.toDouble(),
                                      child: CustomPaint(
                                        painter: ObjectPainter(
                                            objectList: objects,
                                            imageFile: image),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Colors.white,
                                  width: 350,
                                  height: 350,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 53,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          )),
    );
  }
}

class ObjectPainter extends CustomPainter {
  List<DetectedObject> objectList;
  ui.Image imageFile;

  ObjectPainter({required this.objectList, required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      final paint = Paint();
      final rect = Offset.zero & size;
      canvas.drawImageRect(
          imageFile,
          Rect.fromLTWH(
              0, 0, imageFile.width.toDouble(), imageFile.height.toDouble()),
          rect,
          paint);
    }

    Paint p = Paint();
    p.color = Colors.red;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 4;

    // objectList 내의 각 객체에 대해 사각형 그리기
    for (DetectedObject detectedObject in objectList) {
      // boundingBox를 기준으로 사각형 그리기
      canvas.drawRect(detectedObject.boundingBox, p);

      // 레이블이 있는 경우 텍스트를 그리기
      for (Label label in detectedObject.labels) {
        TextSpan span = TextSpan(
          text: "${label.text} (${label.confidence.toStringAsFixed(2)})",
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
            Offset(detectedObject.boundingBox.left,
                detectedObject.boundingBox.top));
        break;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
