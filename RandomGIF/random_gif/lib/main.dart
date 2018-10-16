import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:share/share.dart';

import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

var gif = "";

var image = Uint8List(0);

main() async {
  /*var gifResponse = await getGIF();
  print(gifResponse.body);

  var response = json.decode(gifResponse.body);
  gif = response['data']['images']['original']['url'];

  print(gif);*/

  runApp(new MaterialApp(
    title: 'Random GIF of the Day',
    home: new MainScreen(),
  ));
}

var api_key = {'api_key': 'HRqHraAj9xizhKftgiNlSAntTgDvteVW'};

Future<http.Response> getGIF() {
  return http.get("https://api.giphy.com/v1/gifs/random", headers: api_key);
}

class MainScreen extends StatefulWidget {
  @override
  State createState() => new MainScreenState();
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  bool _visible = true;

  @override
  void initState() {
    loadImage();
  }

  Future loadImage()async {
    setState(() {
      _visible = false;
    });
    var gifResponse = await getGIF();
    var response = json.decode(gifResponse.body);
    gif = response['data']['images']['original']['url'];
    var getImage = await http.readBytes(gif);
    setState(() {
      image = getImage;
      _visible = true;
  });
        }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      /*appBar: new AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: new Text(
          '',
          style: new TextStyle(color: new Color(0xFF343A40), fontSize: 18.0),
        ),
      ),*/
      body: AnimatedBackground(
        particleOptions: const ParticleOptions(
          baseColor: Colors.orange,
          minOpacity: 0.1,
          maxOpacity: 0.4,
          spawnMinSpeed: 70.0,
          spawnMaxSpeed: 100.0,
          spawnMinRadius: 3.0,
          spawnMaxRadius: 6.0,
        ),
        particlePaint: Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = 2.0,
        vsync: this,
        child:  new Center(
        child: new Container(
          child: new Padding(
              padding: new EdgeInsets.only(left: 20.0, right: 20.0,top:54.0),
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Center(child:new Padding(padding: new EdgeInsets.only(top: 50.0), child: CircularProgressIndicator()),),

                        AnimatedOpacity(
                            opacity: _visible ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 500),
                            child: Center(child:Image.memory(image),),
                          ),

                      ],
                    ),
                    new Padding(padding: new EdgeInsets.only(top: 30.0)),
                    new Text(
                      "That's the GIF of the day!",
                      style:
                          new TextStyle(color: Colors.black87, fontSize: 20.0,fontWeight: FontWeight.bold),
                    ),
                    new Padding(padding: new EdgeInsets.only(top: 50.0)),
                    new RaisedButton(
                        padding: const EdgeInsets.all(13.0),
                        color: Colors.amber,
                        textColor: Colors.black,
                        child: new Text(
                          'Me no likey',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        onPressed: () async {
                          loadImage();
                          }
                        ),
                    new Padding(padding: new EdgeInsets.only(top: 20.0)),
                    new RaisedButton(
                        padding: const EdgeInsets.all(13.0),
                        color: Colors.green,
                        textColor: Colors.black,
                        child: new Text(
                          'Share it!',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        onPressed: () {
                          final RenderBox box = context.findRenderObject();
                          Share.share(gif,
                              sharePositionOrigin:
                              box.localToGlobal(Offset.zero) &
                              box.size);
                        }
                    )
                  ])),
        ),
      ),),
    );
  }
}
