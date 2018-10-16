import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_generator/main.dart';

main() async {
  /*var gifResponse = await getGIF();
  print(gifResponse.body);

  var response = json.decode(gifResponse.body);
  gif = response['data']['images']['original']['url'];

  print(gif);*/

  runApp(new MaterialApp(
    theme: new ThemeData(
        //this changes the colour
        hintColor: Colors.amber,
        inputDecorationTheme: new InputDecorationTheme(
            labelStyle: new TextStyle(color: Colors.amber))),
    title: 'Recipe finder',
    home: new MainScreen(),
  ));
}

var foods = [];

Set<String> _ingredients = new Set<String>();

var ingredients = "";

String id = "";

Future<http.Response> searchRecipe(String query) {
  return http.get(
      "http://food2fork.com/api/search?key=c74506f4314de620b7d3ffadc78678ba&q=" +
          query);
}



class MainScreen extends StatefulWidget {
  @override
  State createState() => new MainScreenState();
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  bool _visible = true;
  final controller = TextEditingController();
  List<Widget> chips;
  List<Widget> tiles;
  Paint bg;

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bg = new Paint();
    bg.color = Colors.blue;
  }

  void addIngredient() {
    if(controller.text.length > 1) {
      setState(() {
        print(controller.text);
        _ingredients.add(controller.text);
        controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    chips = _ingredients.map<Widget>((String name) {
      return new Chip(
        key: new ValueKey<String>(name),
        backgroundColor: _nameToColor(name),
        label: new Text(_capitalize(name)),
        onDeleted: () {
          setState(() {
            //_removeMaterial(name);
            _ingredients.remove(name);
          });
        },
      );
    }).toList();

    tiles = <Widget>[
      const SizedBox(height: 8.0, width: 0.0),
      new _ChipsTile(label: '', children: chips),
      const Divider(),
      new Padding(
        padding: const EdgeInsets.all(8.0),
      ),
    ];

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
      body: new Container(
        child: new Padding(
            padding: new EdgeInsets.only(left: 30.0, right: 30.0, top: 54.0),
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new RichText(
                    text: new TextSpan(
                      text: "RECIPE FINDER",
                      style: new TextStyle(
                          //decoration: TextDecoration.lineThrough,
                          //.color(Colors.blue),
                          letterSpacing: 5.0,
                          fontFamily: 'Messages',
                          color: Colors.amber,
                          fontSize: 50.0,
                          fontWeight: FontWeight.bold),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  new Padding(padding: new EdgeInsets.only(top: 50.0)),
                  new Text(
                    "Write your ingredients:",
                    textAlign: TextAlign.left,
                    style: new TextStyle(
                        color: Colors.black87,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                  new Padding(padding: new EdgeInsets.only(top: 10.0)),
                  new Row(
                    children: <Widget>[
                      //new Padding(padding: new EdgeInsets.only(left: 20.0,right: 20.0)),
                      new Expanded(
                          child: new TextField(
                        controller: controller,
                      )),
                      new Padding(
                          padding:
                              new EdgeInsets.only(left: 15.0, right: 15.0)),
                      new OutlineButton.icon(
                        color: Colors.amber,
                        icon: const Icon(Icons.add, size: 18.0),
                        label: const Text(
                          'ADD',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          addIngredient();
                        },
                      ),
                    ],
                  ),
                  new Padding(padding: new EdgeInsets.only(top: 20.0)),
                  new Flexible(
                    child: new ListView(children: tiles),
                  ),
                  new Flexible(
                    child: new Align(
                      alignment: const Alignment(0.0, -0.2),
                      child: new FloatingActionButton(
                        child: const Icon(Icons.arrow_forward),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.amber,
                        onPressed: () {
                          heyHoLetsGo();
                        },
                      ),
                    ),
                  ),
                ])),
      ),
    );
  }

  Future heyHoLetsGo() async {
    String query = "";
    var first = true;
    _ingredients.forEach((String food) {
      if (first) {
        query += food;
        first = false;
      } else
        query += "," + food;
    });

    var recipes = await searchRecipe(query);
    print(recipes.body);
    Navigator.of(context).pushReplacement(
      new CupertinoPageRoute(
          builder: (context) => new RecipesMenuMain(recipes.body)),
    );

  }
}

Color _nameToColor(String name) {
  assert(name.length > 1);
  final int hash = name.hashCode & 0xffff;
  final double hue = (360.0 * hash / (1 << 15)) % 360.0;
  return new HSVColor.fromAHSV(1.0, hue, 0.4, 0.90).toColor();
}

String _capitalize(String name) {
  assert(name != null && name.isNotEmpty);
  return name.substring(0, 1).toUpperCase() + name.substring(1);
}

class _ChipsTile extends StatelessWidget {
  const _ChipsTile({
    Key key,
    this.label,
    this.children,
  }) : super(key: key);

  final String label;
  final List<Widget> children;

  // Wraps a list of chips into a ListTile for display as a section in the demo.
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: children.isEmpty
          ? new Center(
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Text(
            'No ingredients',
            style: Theme
                .of(context)
                .textTheme
                .caption
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      )
          : new Wrap(
        children: children
            .map((Widget chip) => new Padding(
          padding: const EdgeInsets.all(4.0),
          child: chip,
        ))
            .toList(),
      ),
    );
  }
}
