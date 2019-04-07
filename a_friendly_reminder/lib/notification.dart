import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NotificationPage extends StatefulWidget {
    NotificationPage({Key key, this.message}) : super(key: key);
    final String message;

    @override
    _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String message;

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Image.network(
                  'https://www.farmaciacalvario.com/uploads/8168617.jpg',
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
                  "PRECISA DE TOMAR O COMPRIMIDO",
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
                  'Take in cycles of ' + "12H",
                  style: new TextStyle(fontSize: 18),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}