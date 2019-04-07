import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:a_friendly_reminder/medicine.dart';
import 'package:a_friendly_reminder/db_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:a_friendly_reminder/ocr.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:a_friendly_reminder/notification.dart';
import 'package:flutter/cupertino.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

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
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(onDidReceiveLocalNotification: onDidRecieveLocationLocation);
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
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
            return new Container(
              decoration: new BoxDecoration(color: Color(0xffefdfbb)),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
      bottomNavigationBar: buildBottomNavbar(),
    );
  }

  Widget buildMedicineList(AsyncSnapshot<List<Medicine>> snap) {
    return new Container(
      decoration: new BoxDecoration(color: Color(0xffefdfbb),),
      child: ListView.builder(
        itemBuilder: (context, index) {
          Medicine item = snap.data[index];
          return InkWell(
            child: new Column(
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
                              Icons.info,
                              size: 35.0,
                              color: Color(0xff7e482a),
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
            ),
            onTap: () => itemClick(item),
          );
        },
        itemCount: snap.data.length,
      )
    );
  }

  Widget buildBottomNavbar() {
    return new BottomAppBar(
        child: new Container(
          decoration: new BoxDecoration(
            color: Color(0xff7e482a),
            border: new Border(
              top: BorderSide(
                color: Color(0xff5D351C),
                width: 8
              )
            )
          ),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Expanded(
                child: new RaisedButton(
                  onPressed:  getImage,
                  color: Color(0xff7e482a),
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
                          color: Color(0xffefdfbb),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
                        child: new Text(
                          'Adicionar Medicamento',
                          style: new TextStyle(
                            fontSize: 22.0,
                            color: Color(0xffefdfbb),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              /*new Expanded(
                child: new RaisedButton(
                  onPressed: () {},
                    color: Color(0xff7e482a),
                  elevation: 0.0,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                        child: new Icon(
                          Icons.build,
                          size: 52,
                          color: Color(0xffefdfbb),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
                        child: new Text(
                          'Settings',
                          style: new TextStyle(
                            fontSize: 22.0,
                            color: Color(0xffefdfbb),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),*/
            ],
          ),
        )
    );
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => DetailWidget(image, flutterLocalNotificationsPlugin)),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');


  void itemClick(Medicine item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicinePage(medicine: item,)),
    );
  }

  Future onDidRecieveLocationLocation(int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(),
                ),
              );
            },
          )
        ],
      )
    );
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationPage()),
    );
  }
}


class MedicinePage extends StatefulWidget {
  MedicinePage({Key key, this.medicine}) : super(key: key);
  final Medicine medicine;

  @override
  _MedicinePage createState() => _MedicinePage();
}

class _MedicinePage extends State<MedicinePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffefdfbb),
      body: FutureBuilder<List<List<String>>>(
        future: getDoAndDonts(widget.medicine.id),
        builder: (BuildContext context, AsyncSnapshot<List<List<String>>> snapshot){
          //if(snapshot.hasData){
           // return buildMedicineWithInfo(snapshot);
          //}
          //else{
            return buildMedicine();
          //}
        }
      ),
      bottomNavigationBar: buildBottomNavbar(),
    );
  }

  Widget buildMedicine(){
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Expanded(
              child: new Image.file(
                new File(widget.medicine.img),
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        new Row(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(16.0),
              child: new Text(
                widget.medicine.name,
                style: new TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        new Row(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
              child: new Text(
                'Take in cycles of ' + widget.medicine.interval,
                style: new TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget buildMedicineWithInfo(AsyncSnapshot<List<List<String>>> snap){
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Expanded(
              child: new Image.file(
                new File(widget.medicine.img),
                fit: BoxFit.cover,
              ),
            ),
          ]
        ),
        new Row(
          children: <Widget>[
          new Padding(
            padding: new EdgeInsets.all(16.0),
            child: new Text(
              widget.medicine.name,
              style: new TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      new Row(
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
            child: new Text(
              'Take in cycles of ' + widget.medicine.interval,
              style: new TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      new Column(
        children: <Widget>[
          new ListView.builder(
          itemBuilder: (context, index){
            new Text(index == 0 ? "Coisas boas" : "Coisas mas");
            List<String> dos = snap.data[index];
            return new Container(
              child:
                new Text(dos.toString()),
            );
          },
          itemCount: snap.data.length,
        ),
        ],
      )
    ]);
  }

  Future<List<List<String>>> getDoAndDonts(int id) async{
    List<List<String>> all = new List(2);
    all[0] = await DBProvider.db.getDos(id);
    all[1] = await DBProvider.db.getDonts(id);
    return all;
  }

  Widget buildBottomNavbar() {
    return new BottomAppBar(
        child: new Container(
          decoration: new BoxDecoration(
              color: Color(0xff7e482a),
              border: new Border(
                  top: BorderSide(
                      color: Color(0xff5D351C),
                      width: 8
                  )
              )
          ),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Expanded(
                child: new RaisedButton(
                  onPressed:  () {Navigator.pop(context);},
                  color: Color(0xff7e482a),
                  elevation: 0.0,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                        child: new Icon(
                          Icons.arrow_back,
                          size: 52,
                          color: Color(0xffefdfbb),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
                        child: new Text(
                          'Voltar ao início',
                          style: new TextStyle(
                            fontSize: 22.0,
                            color: Color(0xffefdfbb),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              /*new Expanded(
                child: new RaisedButton(
                  onPressed: () {},
                    color: Color(0xff7e482a),
                  elevation: 0.0,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                        child: new Icon(
                          Icons.build,
                          size: 52,
                          color: Color(0xffefdfbb),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
                        child: new Text(
                          'Settings',
                          style: new TextStyle(
                            fontSize: 22.0,
                            color: Color(0xffefdfbb),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),*/
            ],
          ),
        )
    );
  }
}