import 'package:flutter/material.dart';
import 'characters_view.dart';

class MyAppDrawer extends StatefulWidget {
  @override
  _MyAppDrawerState createState() => _MyAppDrawerState();
}

class _MyAppDrawerState extends State<MyAppDrawer> {
  final _myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    _myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Search a charcter by name'),
            decoration: BoxDecoration(
              color: Colors.black12,
            ),
          ),
          ListTile(
              leading: Icon(Icons.people),
              title: TextField(
                controller: _myController,
              )),
          ListTile(
            title: Text('Submit'),
            onTap: () {
              // Update the state of the app
              // ...
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CharactersViewWithName(
                        characterName: _myController.text)),
              );
            },
          ),
          ListTile(
            title: Text('Close'),
            onTap: () {
              // Update the state of the app
              // ...
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}