import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:facelandmarkdetection_flutter/home.dart';
import 'package:facelandmarkdetection_flutter/homesecond.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeSecond(),
    );
  }
}