// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:hsv_color_pickers/hsv_color_pickers.dart';
import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';

// import 'package:opencv_3/opencv_3.dart';
class HomeSecond extends StatefulWidget {
  const HomeSecond({super.key});

  @override
  State<HomeSecond> createState() => _HomeSecondState();
}

class _HomeSecondState extends State<HomeSecond> {
  FacePainter? _facePainter;
  List<CameraDescription> cameras = [];
  late CameraController cameraController;

  File? _imageFile;
  List<Face>? _faces;
  List<FaceMesh>? _facemeshes;
  bool isLoading = false;
  ui.Image? _image;
  final picker = ImagePicker();
  List<int>? landmarkleftPosition;
  List<int>? landmarkrightPosition;
  List<List<int>?>? landmarkPosition;
  List<List<double>> contours = [];
  Color? color = Colors.blue;
  // Future<void> _initialize() async {
  //   try {
  //     cameras = await availableCameras();
  //     cameraController = CameraController(cameras[1], ResolutionPreset.medium);
  //     await cameraController.initialize().then((_) {
  //       if (!mounted) {
  //         return;
  //       }
  //       setState(() {});
  //     });
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _initialize();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HueController controller = HueController(HSVColor.fromColor(Colors.blue));
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _getImage,
          child: Icon(Icons.add_a_photo),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _image != null && _facemeshes != null && color != null
                ? Center(
                    child: Column(
                      children: [
                        FittedBox(
                          child: SizedBox(
                            width: _image!.width.toDouble(),
                            height: _image!.height.toDouble(),
                            child: CustomPaint(
                              painter: FacePainter(_image!, _facemeshes!,
                                  contours, color!, landmarkPosition = []),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          child: Center(
                            child: HuePicker(
                              controller: controller,
                              onChanged: (value) {
                                setState(() {
                                  color = value.toColor();
                                });
                              },
                            ),
                          ),
                        ),
                        // Expanded(child: CameraPreview(cameraController))
                      ],
                    ),
                  )
                : SizedBox.shrink());
  }

  _getImage() async {
    setState(() {
      _image = null;
      contours.clear();
    });
    final imageFile = await picker.pickImage(source: ImageSource.camera);
    final inputImage = InputImage.fromFile(File(imageFile!.path));

    final faceMeshDetector =
        GoogleMlKit.vision.faceMeshDetector(FaceMeshDetectorOptions.faceMesh);
    List<FaceMesh> faces = await faceMeshDetector.processImage(inputImage);
    for (var i in faces) {
      i.contours.forEach((key, value) {
        // log('${[key, value]}');
        List<double> points;
        if (key == FaceMeshContourType.upperLipTop ||
            key == FaceMeshContourType.lowerLipBottom ||
            key == FaceMeshContourType.upperLipBottom ||
            key == FaceMeshContourType.lowerLipTop) {
          value!.forEach((element) {
            print('ponits.........${[element.x, element.y]}');
            setState(() {
              points = [element.x, element.y];
              contours.add(points);
            });
          });
        }
      });
    }
    log(landmarkPosition.toString());
    log(contours.toString());
    if (mounted) {
      setState(() {
        _imageFile = File(imageFile.path);

        _facemeshes = faces;
        _loadImage(_imageFile!);
      });
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
      (value) {
        setState(() {
          _image = value;
          isLoading = false;
        });
      },
    );
  }
}


class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<FaceMesh> faces;
  final List<Rect> rects = [];
  final List<int> id = [];
  final List<List<int>?>? landmarkPosition;
  final List<List<double>>? contours;
  final Color color;

  FacePainter(this.image, this.faces, this.contours, this.color,
      this.landmarkPosition) {
    updateData();
  }
  void updateData() {
    rects.clear();
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = Color.fromARGB(255, 255, 255, 255);

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
      canvas.drawLine(Offset(0, 0), Offset(2, 2), paint);
      // i want to draw line by contour list<list<double>> contour given
      Path path = Path();
      path.moveTo(contours![0][0], contours![0][1]);
      for (int j = 0; j < contours!.length; j++) {
        path.lineTo(contours![j][0], contours![j][1]);
      }
      path.close();


      canvas.drawPath(path, paint);


      Paint fillPaint = Paint()
        ..color = color != null ? color : Colors.blue 
        ..blendMode = BlendMode.screen
        ..style = PaintingStyle.fill; 

      canvas.drawPath(path, fillPaint);
    }
  }

  @override
  bool shouldRepaint(FacePainter old) {
    return image != old.image || faces != old.faces;
  }
}
