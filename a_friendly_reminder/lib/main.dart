import 'dart:async';

import 'package:flutter/material.dart';
import 'package:a_friendly_reminder/pages.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<void> main() async{
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A friendly Reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'A Friendly Reminder', cameras: cameras),
    );
  }
}

