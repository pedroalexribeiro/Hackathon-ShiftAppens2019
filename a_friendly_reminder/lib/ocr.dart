import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class DetailWidget extends StatefulWidget  {

  final File _file;

  DetailWidget(this._file);

  @override
  State<StatefulWidget> createState() {
    return _DetailState();
  }
}

class _DetailState extends State<DetailWidget> {
  List<VisionText> _currentTextLabels = <VisionText>[];
  TextRecognizer textRecognizer;
  FirebaseVisionImage visionImage;

  @override
  void initState() {
    super.initState();
    visionImage = FirebaseVisionImage.fromFile(widget._file);
    textRecognizer = FirebaseVision.instance.textRecognizer();
    Timer(Duration(milliseconds: 1000), () {
      this.analyzeLabels();
    });
  }

  void analyzeLabels() async {
    try {
      var currentLabels;
      currentLabels = await textRecognizer.processImage(visionImage);
      print(currentLabels.text);
      setState(() => _currentTextLabels = currentLabels);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text("Text Recognition"),
        ),
        body: Column(children: <Widget>[
          buildImage(context),
          buildTextList(_currentTextLabels)
        ],));
  }

  Widget buildImage(BuildContext context) {
    return
        Expanded(
            flex: 2,
          child: Container(
              decoration: BoxDecoration(
                color: Colors.black
              ),
              child: Center(
                child: widget._file == null
                    ? Text('No Image')
                    : FutureBuilder<Size>(
                  future: _getImageSize(Image.file(widget._file, fit: BoxFit.fitWidth)),
                  builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                          foregroundDecoration:
                          TextDetectDecoration(_currentTextLabels, snapshot.data),
                          child: Image.file(widget._file, fit: BoxFit.fitWidth));
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              )
          ),
        );

  }

  Widget buildTextList(List<VisionText> texts) {
    if (texts.length == 0) {
      return Expanded(
        flex: 1,
        child: Center(child: Text('No text detected', style: Theme.of(context).textTheme.subhead),
      ));
    }
    return Expanded(
      flex: 1,
      child: Container(
        child: ListView.builder(
            padding: const EdgeInsets.all(1.0),
            itemCount: texts.length,
            itemBuilder: (context, i) {
              return _buildTextRow(texts[i].text);
            }),
      ),
    );
  }

  Widget _buildTextRow(text) {
    return ListTile(
      title: Text(
        "$text",
      ),
      dense: true,
    );
  }


  Future<Size> _getImageSize(Image image) {
    Completer<Size> completer = Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(
            (ImageInfo info, bool _) => completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble())));
    return completer.future;
  }

}

/*
  This code uses the example from azihsoyn/flutter_mlkit
  https://github.com/azihsoyn/flutter_mlkit/blob/master/example/lib/main.dart
*/

class TextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionText> _texts;
  TextDetectDecoration(List<VisionText> texts, Size originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return _TextDetectPainter(_texts, _originalImageSize);
  }
}

class _TextDetectPainter extends BoxPainter {
  final List<VisionText> _texts;
  final Size _originalImageSize;
  _TextDetectPainter(texts, originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var text in _texts) {
      final _rect = Rect.fromLTRB(
          offset.dx + text.blocks.length / _widthRatio,
          offset.dy + text.blocks.length / _heightRatio,
          offset.dx + text.blocks.length / _widthRatio,
          offset.dy + text.blocks.length / _heightRatio);
      canvas.drawRect(_rect, paint);
    }
    canvas.restore();
  }
}