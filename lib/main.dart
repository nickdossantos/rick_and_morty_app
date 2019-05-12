import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'characters_view.dart';
import 'location.dart';
import 'locations_view.dart';
import 'episodes_view.dart';

void main() => runApp(new MyApp());

// Main App layout
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "My App", theme: ThemeData.dark(), home: Home());
  }
}

// Child of Home of my app, parent is AppModel()
// Used to
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Rick and Morty"),
          actions: <Widget>[IconButton(
            icon: Icon(Icons.tv),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EpisodesView()),
              );
            },
          ),IconButton(
            icon: Icon(Icons.location_on),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LocationsView()),
              );
            },
          ),IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedCharacterView()),
              );
            },
          ),],
        ),
        drawer: new MyAppDrawer(),
        body: Center(child: CharactersView()));
  }
}

