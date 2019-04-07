import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:a_friendly_reminder/db_provider.dart';
import 'package:a_friendly_reminder/medicine.dart';
import 'package:a_friendly_reminder/pages.dart';

class DetailWidget extends StatefulWidget  {

  final File _file;

  DetailWidget(this._file);

  @override
  State<StatefulWidget> createState() {
    return _DetailState();
  }
}

class _DetailState extends State<DetailWidget> {
  VisionText _currentTextLabels;
  TextRecognizer textRecognizer;
  FirebaseVisionImage visionImage;

  @override
  void initState(){
    super.initState();
    visionImage = FirebaseVisionImage.fromFile(widget._file);
    textRecognizer = FirebaseVision.instance.textRecognizer();
    this.analyzeLabels();
  }

  Future<Medicine> verifyError() async{
    var ofc;
    for (TextBlock block in _currentTextLabels.blocks) {
      for (TextLine line in block.lines) {
        Medicine dbMed = await DBProvider.db.getMedicineByName(line.text);
        if (dbMed != null) {
          return dbMed;
        }
      }
    }
    return ofc;
  }

  void analyzeLabels() async {
    try {
      VisionText currentLabels;
      currentLabels = await textRecognizer.processImage(visionImage);
      print(currentLabels.text);

      setState(() {
        _currentTextLabels = currentLabels;
      });
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Medicine>(
        future: verifyError(),
        builder: (BuildContext context, AsyncSnapshot<Medicine> snapshot){
          if(snapshot.hasData){
            return new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Text('A que horas quer começar a tomar?'),
                  ],
                ),
                new Row(
                  children: <Widget>[
                    new RaisedButton(
                      child: new Text('Definir alarme'),
                      onPressed: () {
                        DatePicker.showTimePicker(context,
                          showTitleActions: true,
                          onChanged: (time) {
                            print('change $time');
                          }, onConfirm: (time) {
                            DBProvider.db.newMedicine(snapshot.data, time);
                              Navigator.pop(context);
                          }, currentTime: DateTime.now(), locale: LocaleType.pt);
                      },
                    )
                  ],
                )
              ],
            );
          }else{
            return Center(child: CircularProgressIndicator());
          }
        }
      )
    );
  }
}