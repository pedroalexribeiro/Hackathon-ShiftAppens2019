import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:a_friendly_reminder/medicine.dart';
import 'package:a_friendly_reminder/db_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.cameras}) : super(key: key);
  final String title;
  final List<CameraDescription> cameras;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  bool _autoFocusOcr = true;
  bool _torchOcr = false;
  bool _multipleOcr = false;
  bool _waitTapOcr = false;
  bool _showTextOcr = true;
  Size _previewOcr;
  List<OcrText> _textsOcr = [];
  CameraController controller;
  String imagePath;
  String videoPath;
  List<Medicine> medicines;

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Medicine>>(
        future: DBProvider.db.getAllMedicine(),
        builder: (BuildContext context, AsyncSnapshot<List<Medicine>> snapshot) {
          if (snapshot.hasData) {
            return buildMedicineList(snapshot);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: buildBottomNavbar(),
    );
  }

  Widget buildMedicineList(AsyncSnapshot<List<Medicine>> snap) {
    return new Container(
      decoration: new BoxDecoration(color: Color(0xfff5f6f1)),
      child: ListView.builder(
        itemBuilder: (context, index) {
          Medicine item = snap.data[index];
          return new Column(
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
                        child: new Text(
                          item.name,
                          style: new TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
                        child: new Text(
                          "Take in cycles of " + item.interval,
                          style: new TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Icon(
                            Icons.star_border,
                            size: 35.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              new Divider(
                height: 2.0,
                color: Colors.grey,
              )
            ],
          );
        },
        itemCount: snap.data.length,
      )
    );
  }

  Widget buildBottomNavbar() {
    return new BottomAppBar(
        child: new Container(
          decoration: new BoxDecoration(color: Color(0xff9b3d3d)),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Expanded(
                child: new RaisedButton(
                  onPressed:  controller != null &&
                              controller.value.isInitialized &&
                              !controller.value.isRecordingVideo
                              ? onTakePictureButtonPressed
                              : null,
                  color: Color(0xff9b3d3d),
                  elevation: 0.0,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                        child: new Icon(
                          Icons.photo_camera,
                          size: 52,
                          color: Color(0xfff5f6f1),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
                        child: new Text(
                          'Camera',
                          style: new TextStyle(
                            fontSize: 22.0,
                            color: Color(0xfff5f6f1),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              new Expanded(
                child: new RaisedButton(
                  onPressed: () {},
                  color: Color(0xff9b3d3d),
                  elevation: 0.0,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                        child: new Icon(
                          Icons.settings,
                          size: 52,
                          color: Color(0xfff5f6f1),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
                        child: new Text(
                          'Settings',
                          style: new TextStyle(
                            fontSize: 22.0,
                            color: Color(0xfff5f6f1),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              /*
          new Expanded(
            child: new RaisedButton(
              elevation: 0.0,
              splashColor: Colors.pinkAccent,
              color: Colors.white,
              child:
              new Text(
                "Camera",
                style: new TextStyle(fontSize: 20.0, color: Colors.black),
              ),
              onPressed: () {},
            ),
          ),
          new Expanded(
            child: new RaisedButton(
              elevation: 0.0,
              splashColor: Colors.pinkAccent,
              color: Colors.white,
              child: new Text(
                "Settings",
                style: new TextStyle(fontSize: 20.0, color: Colors.black),
              ),
              onPressed: () {},
            ),
          ),
          */
            ],
          ),
        )
    );
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      //showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        //if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  Future<Null> _read() async {
    List<OcrText> texts = [];
    try {
      texts = await FlutterMobileVision.read(
        flash: _torchOcr,
        autoFocus: _autoFocusOcr,
        multiple: _multipleOcr,
        waitTap: _waitTapOcr,
        showText: _showTextOcr,
        preview: _previewOcr,
        camera: _cameraOcr,
        fps: 2.0,
      );
    } on Exception {
      texts.add(new OcrText('Failed to recognize text.'));
    }

    if (!mounted) return;

    setState(() => _textsOcr = texts);
  }

  void initCamera(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        //showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    //showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');
}