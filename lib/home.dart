// ignore_for_file: use_build_context_synchronously, sized_box_for_whitespace, prefer_const_constructors

import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:opencv_ffi/opencv_ffi.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CameraDescription> cameras = [];
  List<Face>? faces;
  late CameraController cameraController;
  // late FaceDetector faceDetector;
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
      enableTracking: true,
    ),
  );
  Future<XFile> pickImage() async {
    final picker = ImagePicker();
    final res = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      files = File(res!.path);
    });
    return res!;
  }

  Future<void> _initialize() async {
    try {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[1], ResolutionPreset.medium);
      await cameraController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
      // await faceDetector.initialize();
      // _startImageStream();
      // cameraController.startImageStream((image) async {
      //   final bytesList = image.planes.map((plane) {
      //     return plane.bytes;
      //   }).toList();
      //   final bytes =
      //       Uint8List.fromList(bytesList.expand((list) => list).toList());
      //   final faces = await faceDetector.processImage(InputImage.fromBytes(
      //       bytes: bytes,
      //       metadata: InputImageMetadata(
      //           size: Size(image.width.toDouble(), image.height.toDouble()),
      //           rotation: InputImageRotation.rotation90deg,
      //           format: InputImageFormat.yuv420,
      //           bytesPerRow: image.planes.first.bytesPerRow)));
      //   log(faces.toString());
      //   // faceDetector.close();
      // });
    } on CameraException catch (e) {
      // Handle camera exception
      // log(e.description.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _initialize();
  }

  File? files;
  int? top, left;
  FaceContour? uppercontour;
  FaceContour? lowercontour;
  FaceContour? upperLipcontour;
  FaceContour? lowerLipcontour;
  @override
  Widget build(BuildContext context) {
    Path contourPath = Path();
    return Scaffold(
        appBar: AppBar(title: const Text("Camera")),
        body: Stack(alignment: Alignment.bottomCenter, children: [
          files != null
              ? Stack(children: [
                  Container(
                    // height: 400,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: FileImage(files!),
                    )),
                  ),
                  if (uppercontour != null)
                    for (var i in uppercontour!.points)
                      files != null && faces != null
                          ? LipContourWidget(uppercontour!.points)
                          : SizedBox.shrink(),
                  if (lowercontour != null)
                    for (var i in lowercontour!.points)
                      if (files != null && faces != null)
                        LipContourWidget(lowercontour!.points),
                  if (upperLipcontour != null)
                    for (var i in upperLipcontour!.points)
                      if (files != null && faces != null)
                        LipContourWidget(upperLipcontour!.points),
                  if (lowerLipcontour != null)
                    for (var i in lowerLipcontour!.points)
                      if (files != null && faces != null)
                        LipContourWidget(lowerLipcontour!.points),
                  // files != null && faces != null
                  //     ? Positioned(
                  //         top: faces![0].boundingBox.top,
                  //         // bottom: faces![0].boundingBox.bottom,
                  //         left: faces![0].boundingBox.left,
                  //         // right: faces![0].boundingBox.right,
                  //         // bottom: faces[0].boundingBox.bottom,
                  //         // right: faces[0].boundingBox.right,
                  //         width: faces![0].boundingBox.width,
                  //         height: faces![0].boundingBox.height,
                  //         child: Container(
                  //             width: faces![0].boundingBox.width,
                  //             height: faces![0].boundingBox.height,
                  //             decoration: BoxDecoration(
                  //                 color: Color.fromARGB(83, 0, 0, 0),
                  //                 border:
                  //                     Border.all(color: Colors.white, width: 2),
                  //                 borderRadius: BorderRadius.circular(20)),
                  //             child: Center(
                  //                 child: Text(
                  //               "Dada",
                  //               style: TextStyle(
                  //                   color: Colors.yellow, fontSize: 20),
                  //             ))))
                  //     : SizedBox.shrink(),
                ])
              : SizedBox.shrink(),
          files != null && faces != null
              ? Container(
                  height: MediaQuery.of(context).size.height / 6,
                  color: Color.fromARGB(83, 0, 0, 0),
                  child: ListView.builder(
                    itemCount: faces!.length,
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(uppercontour!.points.toString(),
                              style: TextStyle(color: Colors.yellow)),
                          Text(faces![index].boundingBox.top.toString(),
                              style: TextStyle(color: Colors.yellow)),
                          Text(faces![index].boundingBox.left.toString(),
                              style: TextStyle(color: Colors.yellow))
                        ],
                      );
                    },
                  ),
                )
              : SizedBox.shrink(),
        ]),
        floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            isExtended: true,
            onPressed: () async {
              final file = await pickImage();
              final image = File(file.path);
              setState(() {
                files = File(file.path);
              });
              final faces = await faceDetector
                  .processImage(InputImage.fromFile(image))
                  //     .then((value) {
                  //   setState(() {
                  //     this.faces = value;
                  //   });
                  // });
                  .then((value) {
                setState(() {
                  this.faces = value;
                });
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Text(uppercontour!.points.toString()),
                                Text(value[index].boundingBox.top.toString()),
                                Text(value[index].boundingBox.left.toString())
                              ],
                            );
                          },
                        ),
                      );
                    });
                value.forEach((element) {
                  element.contours.forEach((key, value) {
                    print('faces.........${[key.name, value?.points]}');
                    setState(() {
                      if (key.name == 'upperLipTop') {
                        this.uppercontour = value;
                      }
                      if (key.name == 'lowerLipBottom') {
                        this.lowercontour = value;
                      }
                      if (key.name == 'upperLipBottom') {
                        this.upperLipcontour = value;
                      }
                      if (key.name == 'lowerLipTop') {
                        this.lowerLipcontour = value;
                      }
                      element.landmarks.forEach((key, value) {
                        print([key.name, value!.position]);
                      });
                    });
                  });
                });
              });
            },
            child: Icon(Icons.camera)));
  }
}

class LipContourPainter extends CustomPainter {
  final List<Point> lipContours;

  LipContourPainter(this.lipContours);

  @override
  void paint(Canvas canvas, Size size) {
    if (lipContours.length < 3) {
      // Not enough points to form a polygon
      return;
    }

    final paint = Paint()
      ..color = Colors.red // Set the color of the polygon
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    final path = Path();
    final firstPoint = lipContours.first;
    path.moveTo(firstPoint.x.toDouble(), firstPoint.y.toDouble());

    for (var i = 1; i < lipContours.length; i++) {
      final currentPoint = lipContours[i];
      path.lineTo(currentPoint.x.toDouble(), currentPoint.y.toDouble());
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class LipContourWidget extends StatelessWidget {
  final List<Point> lipContours; // Your list of lip contour points

  LipContourWidget(this.lipContours);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LipContourPainter(lipContours),
      child: Container(), // You can put other widgets here if needed
    );
  }
}
