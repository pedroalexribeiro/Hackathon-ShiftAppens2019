import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:a_friendly_reminder/db_provider.dart';
import 'package:a_friendly_reminder/medicine.dart';

class DetailWidget extends StatefulWidget  {

  final File _file;
  final FlutterLocalNotificationsPlugin pulgin;

  DetailWidget(this._file, this.pulgin);

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
    var ofc = new Medicine(id: -1, name: "erro", interval: "0", img: "path");
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
            if(snapshot.data.id == -1){
              return new Container(
                  decoration: new BoxDecoration(
                      color: Color(0xffefdfbb)
                  ),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new Center(
                              child: new Padding(
                                padding: new EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 0.0),
                                child: new Text(
                                  'Não conseguimos encontrar nenhum medicamento com esse nome, por favor tente novamente',
                                  style: new TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new Center(
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(32.0, 64.0, 32.0, 0.0),
                                  child: new SizedBox(
                                    width: double.infinity,
                                    height: 128,
                                    child: new RaisedButton(
                                      color: Color(0xff7e482a),
                                      child: new Text(
                                        'Voltar ao início',
                                        style: new TextStyle(
                                          color: Color(0xffefdfbb),
                                          fontSize: 18,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  )
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
              );
            }else{
              return new Container(
                decoration: new BoxDecoration(
                  color: Color(0xffefdfbb)
                ),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Center(
                            child: new Text(
                              'A que horas quer começar a tomar?',
                              style: new TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(32.0, 64.0, 32.0, 0.0),
                              child: new SizedBox(
                                width: double.infinity,
                                height: 128,
                                child: new RaisedButton(
                                  color: Color(0xff7e482a),
                                  child: new Text(
                                    'Definir alarme',
                                    style: new TextStyle(
                                      color: Color(0xffefdfbb),
                                      fontSize: 18,
                                    ),
                                  ),
                                  onPressed: () {
                                    DatePicker.showTimePicker(context,
                                        showTitleActions: true,
                                        onChanged: (time) {
                                          print('change $time');
                                        }, onConfirm: (time) {
                                          DBProvider.db.newMedicine(snapshot.data, time, widget.pulgin, widget._file.path);
                                          Navigator.pop(context);
                                        }, currentTime: DateTime(0, 0, 0, 20), locale: LocaleType.pt);
                                  },
                                ),
                              )
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )
              );
            }
          }else{
            return new Container(
              decoration: new BoxDecoration(color: Color(0xffefdfbb)),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        }
      )
    );
  }
}