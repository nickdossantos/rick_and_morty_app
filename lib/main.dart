import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Character {
  static String charactersEndpoint =
      "https://rickandmortyapi.com/api/character/?page=";
  static String characterURLWithName =
      "https://rickandmortyapi.com/api/character/?name=";
  final String name;
  final String status;
  final String species;
  final String gender;
  final String origin;
  final String location;
  final String iconUrl;

  Character(
      {this.name,
      this.status,
      this.species,
      this.gender,
      this.origin,
      this.location,
      this.iconUrl});

  static Future<List<Character>> fetchAllWithName(String name) async {
    final response = await http.get(characterURLWithName + name);

    if (response.statusCode == 200) {
      List<Character> characters = [];
      final items = json.decode(response.body)['results'];
      for (Map item in items) {
        characters.add(Character(
            name: item["name"],
            status: item["status"],
            species: item["species"],
            gender: item["gender"],
            origin: item["origin"]["name"],
            location: item["location"]["name"],
            iconUrl: item["image"]));
      }
      return characters;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }
}

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
        ),
        drawer: new MyAppDrawer(),
        body: Center(child: CharactersView()));
  }
}

class CharactersView extends StatefulWidget {
  //WeatherInfo _currentWeatherInfo;

  @override
  _CharactersViewState createState() => new _CharactersViewState();
}

class _CharactersViewState extends State<CharactersView> {
  int page = 1;

  List<Character> data = [];
  Future<List<Character>> getData() async {
    var response = await http.get(Character.charactersEndpoint + page.toString());
    final items = json.decode(response.body)['results'];
    List<Character> characters = [];
    for (Map item in items) {
      characters.add(Character(
          name: item["name"],
          status: item["status"],
          species: item["species"],
          gender: item["gender"],
          origin: item["origin"]["name"],
          location: item["location"]["name"],
          iconUrl: item["image"]));
    }

    this.setState(() {
      page++;
      data = data + characters;
    });
    return data;
  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                getData();
              }
            },
            child: new ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                    if (data.length > 1) {
                    return new ListTile(
                        leading: Image.network(data[index].iconUrl, width: 70, height: 70,),
                        title: Text(data[index].name),
                        subtitle: Text("Status: ${data[index].status}"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CharacterBio(character: data[index])),
                          );
                        });
                  } else {
                    return CircularProgressIndicator();
                  }
                })));
  }
}

class CharactersViewWithName extends StatelessWidget {
  //WeatherInfo _currentWeatherInfo;
  final String characterName;

  CharactersViewWithName({
    Key key,
    @required this.characterName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text("Search Results"), actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.home),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ]),
      drawer: new MyAppDrawer(),
      body: FutureBuilder(
          future: Character.fetchAllWithName(characterName),
// note the builder potentially returns one of three different widgets
          builder:
              (BuildContext context, AsyncSnapshot<List<Character>> snapshot) {
            if (snapshot.hasData) {
              var characters = snapshot.data;

              return new ListView.builder(
                itemCount: characters.length,
                itemBuilder: (BuildContext context, int index) {
                  return new ListTile(
                      leading: Image.network(characters[index].iconUrl, width: 70, height: 70,),
                      title: Text(characters[index].name),
                      subtitle: Text("Status: ${characters[index].status}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CharacterBio(character: characters[index])),
                        );
                      });
                },
              );
            } else if (snapshot.hasError) {
              return Text(
                  "Error fetching data ${snapshot.error} ${snapshot.error.runtimeType}");
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}

class CharacterBio extends StatelessWidget {
  final Character character;
  CharacterBio({
    Key key,
    @required this.character,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(character.name),
        ),
        body: Center(
            child: Column(children: <Widget>[
          Image.network(character.iconUrl, fit: BoxFit.fitWidth),
          new Expanded(
              child: ListView(
            children: <Widget>[
              new ListTile(title: Text("Origin: ${character.name}")),
              new ListTile(title: Text("Status: ${character.status}")),
              new ListTile(title: Text("Gender: ${character.gender}")),
              new ListTile(title: Text("Species: ${character.species}")),
              new ListTile(title: Text("Origin: ${character.origin}")),
              new ListTile(title: Text("Location: ${character.location}")),
            ],
          ))
        ])));
  }
}

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
