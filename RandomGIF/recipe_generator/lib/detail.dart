import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './tile.dart';
import './beers.dart';
import 'package:http/http.dart' as http;

class BeerDetail extends StatefulWidget {
  final Beer beer;
  final CurvedAnimation animation;
  final VoidCallback onAction;

  BeerDetail({this.beer, this.animation, this.onAction});

  @override
  _BeerDetailState createState() => new _BeerDetailState();
}

class _BeerDetailState extends State<BeerDetail> {
  bool _visible = false;
  bool _loaded = false;
  List<dynamic> ingredients = List<dynamic>();

  @override
  Future initState() {
    if(widget.beer.isDark){
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
    Future.delayed(Duration(milliseconds: 250)).then((v){
      setState(() {
        _visible = true;
      });
    });

    loadAndFill();


    super.initState();
  }

  void loadAndFill()async {
    var response = await getRecipe();
    var recipe = json.decode(response.body);
    ingredients = recipe['recipe']['ingredients'];
    setState(() {
      _loaded = true;
    });
  }

  Future<http.Response> getRecipe() {
    return http.get(
        "http://food2fork.com/api/get?key=c74506f4314de620b7d3ffadc78678ba&rId=" +
            widget.beer.size);
  }

  @override
  Widget build(BuildContext context) {
    Beer beer = widget.beer;
    String ingredientsText = "";
    ingredients.forEach((dynamic ingredient) {
        ingredientsText += '• ' +ingredient + '\n\n';

    });
    if(ingredientsText.length > 2)ingredientsText = ingredientsText.substring(0,ingredientsText.length-2);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              BeerTile(
                isHeader: true,
                beer: beer,
                animation: widget.animation,
                onAction: widget.onAction,
              ),
              new Expanded(
                child: _loaded == false ? Center(child:CircularProgressIndicator()) :
                SingleChildScrollView(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child: Text(
                          'Ingredients',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: beer.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
                        child: Text(ingredientsText,),
                      ),
                      Divider(height: 10.0, indent: 35.0,),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child: Text(
                          'Word from the Maker',
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
                        child: Text(beer.word,),
                      ),
                      Container(
                        color: beer.color.withAlpha(120),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(right: 15.0, left: 15.0, top: 15.0),
                              child: Text(
                                'Food Matches',
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.body2.copyWith(
                                  color: beer.isDark ? Colors.white : Colors.black
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
                              child: Text(beer.foodMatch,
                                style: TextStyle(
                                  color: beer.isDark ? Colors.white : Colors.black
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(beer.size, style: Theme.of(context).textTheme.body1,),
                            Text('From \$48.00', style: Theme.of(context).textTheme.subhead.copyWith(fontWeight: FontWeight.w500),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: FlatButton(
                    color: Colors.grey.shade300,
                    onPressed: (){},
                    child: Text('Order'),
                  ),
                ),
              ),
            ],
          ),
          new AnimatedPositioned(
            top: _visible ? 35.0 : 0.0,
            left: 10.0,
            height: 60.0,
            width: 50.0,
            duration: Duration(milliseconds: 150),
            curve: Curves.bounceInOut,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              curve: Curves.linear,
              opacity: _visible ? 1.0 : 0.0,
              child: IconButton(
                icon: Icon(Icons.clear),
                color: Colors.white,
                onPressed: (){
                  setState(() {
                    _visible = false;
                  });
                  widget.onAction != null ? widget.onAction() : null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
