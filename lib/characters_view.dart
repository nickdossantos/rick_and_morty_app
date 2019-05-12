import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'character.dart';
import 'app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Set<int> saved = Set<int>();

class CharactersView extends StatefulWidget {
  //WeatherInfo _currentWeatherInfo;
  @override
  _CharactersViewState createState() => new _CharactersViewState();
}

class _CharactersViewState extends State<CharactersView> {
  int page = 1;
  List<Character> data = [];
  Future<List<Character>> getData() async {
    var response =
    await http.get(Character.charactersEndpoint + page.toString());
    final items = json.decode(response.body)['results'];
    List<Character> characters = [];
    for (Map item in items) {
      characters.add(Character(
          name: item["name"],
          id: item["id"],
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
    this.getSavedCharacters();
  }

  getSavedCharacters() async {
    final QuerySnapshot result = await Firestore.instance
        .collection('characters').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if(documents.length > 0){
      for(var document in documents){
        saved.add(document['id']);
      }
    }
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
                    return _buildRow(data[index], index);
                  } else {
                    return CircularProgressIndicator();
                  }
                })));
  }

  Widget _buildRow(Character character, int index) {
     final bool _alreadySaved = saved.contains(character.id);
    return ListTile(
        leading: Image.network(
          character.iconUrl,
          width: 70,
          height: 70,
        ),
        title: Text(character.name),
        subtitle: Text("${character.status}"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CharacterBio(character: character)),
          );
        },
        trailing: FutureBuilder(future: doesCharacterAlreadyExist(character),
        builder: (BuildContext context, AsyncSnapshot<bool> result) {
          if (result.hasData) {
            return new IconButton(
                icon: Icon(
                  _alreadySaved ? Icons.favorite : Icons.favorite_border,
                  color: _alreadySaved ? Colors.red : null,
                ),
                onPressed: () async {
                  if (_alreadySaved) {
                    saved.remove(character.id);
                    deleteFavorite(character);
                  } else {
                    saved.add(character.id);
                    Firestore.instance.collection("characters")
                        .document()
                        .setData({
                      'iconUrl': character.iconUrl,
                      'id': character.id,
                      'location': character.location,
                      'name': character.name,
                      'species': character.species,
                      'status': character.status
                    });
                  }
                  setState(() {

                  });
                });
          }else{return CircularProgressIndicator();}
        }));}
  Future<bool>doesCharacterAlreadyExist(Character character) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('characters')
        .where('id', isEqualTo: character.id)
        .limit(1)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    return documents.length == 1;
  }
  deleteFavorite(Character character) async{
    final QuerySnapshot result = await Firestore.instance
        .collection('characters')
        .where('id', isEqualTo: character.id)
        .limit(1)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    Firestore.instance
        .collection('characters').document(documents.first.documentID)
        .delete();
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
                      leading: Image.network(
                        characters[index].iconUrl,
                        width: 70,
                        height: 70,
                      ),
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
                      new ListTile(leading: Icon(Icons.people), title: Text(character.name)),
                      new ListTile(leading: Icon(Icons.insert_emoticon),title: Text(character.status)),
                      new ListTile(leading: Icon(Icons.face), title: Text(character.gender)),
                      new ListTile(leading: Icon(Icons.people_outline), title: Text(character.species)),
                      new ListTile(leading: Icon(Icons.home),title: Text(character.origin)),
                      new ListTile(leading: Icon(Icons.location_on),title: Text(character.location)),
                    ],
                  ))
            ])));
  }
}

class SavedCharacterView extends StatefulWidget {
  //WeatherInfo _currentWeatherInfo;
  @override
  _SavedCharacterView createState() {
    return _SavedCharacterView();
  }
}

class _SavedCharacterView extends State<SavedCharacterView> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(title: Text("Saved Characters"),
            actions: <Widget>[
            ]),
        body: _buildBody(context)
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document){
    return new ListTile(
        leading: Image.network(
          document["iconUrl"],
          width: 70,
          height: 70,
        ),
        title: Text(document["name"]),
        subtitle: Text("Status: ${document["status"]}"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CharacterBio(character: Character(iconUrl: document["iconUrl"], id: document["id"], location: document["location"], name: document["name"], origin: document["origin"], species: document["species"], status: document["status"]))),
          );
        }
        );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('characters').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return ListView.builder(itemExtent: 80.0, itemCount: snapshot.data.documents.length,itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]));
      },
    );
  }

}

