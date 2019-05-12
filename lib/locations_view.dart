import 'package:flutter/material.dart';
import 'location.dart';
import 'character.dart';
import 'characters_view.dart';
import 'package:intl/intl.dart';

class LocationsView extends StatelessWidget {
  //WeatherInfo _currentWeatherInfo;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text("Locations"),),
      body: FutureBuilder(
          future: Location.fetchAllLocations(),
// note the builder potentially returns one of three different widgets
          builder:
              (BuildContext context, AsyncSnapshot<List<Location>> snapshot) {
            if (snapshot.hasData) {
              var locations = snapshot.data;

              return new ListView.builder(
                itemCount: locations.length,
                itemBuilder: (BuildContext context, int index) {
                  return new ListTile(
                      title: Text(locations[index].name),
                      subtitle: Text("Status: ${locations[index].type}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LocationBio(location: locations[index])),
                        );
                      }
                  );
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

class LocationBio extends StatelessWidget {
  final Location location;
  LocationBio({
    Key key,
    @required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(location.name),
        ),
        body: Column(
          children: <Widget>[
            ListView(padding: const EdgeInsets.all(8.0),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), children: <Widget>[

                  new ListTile(
                      leading: Icon(Icons.location_city), title: Text(" ${location.name}")),
                  new ListTile(
                      leading: Icon(Icons.my_location),
                      title: Text("${location.dimension}")),
                  new ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(" ${location.type}")),
                  new ListTile(
                      leading: Icon(Icons.cake),
                      title: Text(" ${DateFormat('dd-MM-yyyy').format(DateTime.parse(location.created))}")),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Characters",
                        style: Theme.of(context).textTheme.title,
                      ))
                ]),
            Expanded( child: FutureBuilder(
                future: Character.getListOfCharacters(location.characters),
// note the builder potentially returns one of three different widgets
                builder: (BuildContext context,
                    AsyncSnapshot<List<Character>> snapshot) {
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
                            subtitle:
                            Text("Status: ${characters[index].status}"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CharacterBio(
                                        character: characters[index])),
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
                })),
          ],
        ));
  }
}