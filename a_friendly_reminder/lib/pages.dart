import 'dart:async';

import 'package:flutter/material.dart';
import 'package:a_friendly_reminder/medicine.dart';
import 'package:a_friendly_reminder/db_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:a_friendly_reminder/ocr.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imagePath;
  List<Medicine> medicines;

  @override
  void initState() {
    super.initState();
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
                  onPressed: getImage,
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

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => DetailWidget(image)),
      );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');
}