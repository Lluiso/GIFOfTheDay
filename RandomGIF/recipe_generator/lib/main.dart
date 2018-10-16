import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import './beers.dart';
import './tile.dart';
import './detail.dart';




class RecipesMenuMain extends StatefulWidget {
  //BeersMenuMain({Key key}) : super(key: key);

  String _response;

  RecipesMenuMain(this._response);

  @override
  _BeersMenuState createState() => new _BeersMenuState(_response);
}

class _BeersMenuState extends State<RecipesMenuMain> with TickerProviderStateMixin {
  Map<int, AnimationController> controllerMaps = new Map();
  Map<int, CurvedAnimation> animationMaps = new Map();
  String _response;

  _BeersMenuState(this._response);

  @override
  void initState() {
    beers = [];
    var recipes = json.decode(_response);
    for(int i = 0; i < recipes['count'];++i){
      var recipe = recipes['recipes'][i];
      Beer beer = Beer(
        id: i,
        title: recipe['title'],
        rating: 3.5,
          word: 'Kölsch is the local brew of the city of Cologne in Southern Germany. Our version has all New Zealand ingredients. A great entry level craft beer to quench that lawn mowing thirst.',
          alcohol: 4.5,
          size: recipe['recipe_id'],
          note: 'Some say she’s the luxe life. Exuberant. Snappy. Bright. Chatty. Sunlit. Lush. Passionfruit. Blueberries. Sparkling. Refined. Considered. Dry. And frankly, refreshing.',
          foodMatch: 'Ceasar Salad, Mature Cheddar, Fish & Chips',
          image: 'spoon',
          color: Color.fromRGBO(234, 188, 48, 1.0),
        imageUrl: recipe['image_url']
      );

      beers.add(beer);
    }

    beers.forEach((Beer beer){
      AnimationController _controller = AnimationController(duration: Duration(milliseconds: 400), vsync: this,);
      CurvedAnimation _animation = new CurvedAnimation(parent: _controller, curve: Curves.easeIn);

      controllerMaps[beer.id] = _controller;
      _controller.addStatusListener((AnimationStatus status){
        if(status == AnimationStatus.completed){
          _handleHero(beer);
        }
      });
      animationMaps[beer.id] = _animation;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.grey.shade200,
      ),
      child: Scaffold(
        appBar: new AppBar(
          title: new Text('Recipes', style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey.shade500
          ),),
          elevation: 0.0,
        ),
        body: ListView.builder(
          itemBuilder: (context, index){
            Beer beer = beers[index];
            AnimationController _controller = controllerMaps[beer.id];
            CurvedAnimation _animation = animationMaps[beer.id];
            return BeerTile(
              beer: beer,
              isHeader: false,
              animation: _animation,
              onAction: (){
                _controller.forward();
              },
            );
          },
          itemCount: beers.length,
        ),
      ),
    );
  }

  void _handleHero(Beer beer) {
    AnimationController _controller = controllerMaps[beer.id];
    CurvedAnimation _animation = animationMaps[beer.id];
    Navigator.push(context,
      MaterialPageRoute(builder: (context){
        return BeerDetail(
          beer: beer,
          animation: _animation,
          onAction: (){
            Navigator.pop(context);
          },
        );
      }, fullscreenDialog: true)
    ).then((value){
      Future.delayed(Duration(milliseconds: 600)).then((v){
        _controller.reverse();
      });
    });
  }
}
