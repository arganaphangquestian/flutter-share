import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart' as syspaths;

void main() {
  runApp(Application());
}

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey _shareKey = new GlobalKey();
  Uint8List? shareImg;

  Future<bool> _capturePng() async {
    try {
      var boundary =
          _shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData?.buffer.asUint8List();
      setState(() {
        shareImg = pngBytes;
      });
      // Save to tmp folder
      final appDir = await syspaths.getTemporaryDirectory();
      String path = '${appDir.path}/${DateTime.now().millisecond}.png';
      File file = File(path);
      await file.writeAsBytes(pngBytes!.toList());
      await Share.shareFiles([path], text: 'Great bill recipe');
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: RepaintBoundary(
                  key: _shareKey,
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Center(
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Username",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: shareImg == null
                    ? Center(child: Text("Image Empty"))
                    : Image.memory(shareImg!),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        onPressed: () {
          /*
          * 
          * Do some magic here
          *
          */
          _capturePng().then((value) {
            if (value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Share successfully"),
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Share failed"),
              ));
            }
          }).catchError((e) {
            print('Error :$e');
          });
        },
        child: Text("Share"),
      ),
    );
  }
}

class ButtonShare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
