import 'package:flutter/material.dart';
import 'episode.dart';
import 'character.dart';
import 'characters_view.dart';

class EpisodesView extends StatelessWidget {
  //WeatherInfo _currentWeatherInfo;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Episodes"),
      ),
      body: FutureBuilder(
          future: Episode.fetchEpisodes(),
// note the builder potentially returns one of three different widgets
          builder:
              (BuildContext context, AsyncSnapshot<List<Episode>> snapshot) {
            if (snapshot.hasData) {
              var episodes = snapshot.data;

              return new ListView.builder(
                itemCount: episodes.length,
                itemBuilder: (BuildContext context, int index) {
                  return new ListTile(
                      title: Text(episodes[index].name),
                      subtitle: Text("${episodes[index].episode}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EpisodeBio(episode: episodes[index])),
                        );
                      });
                },
              );
            } else if (snapshot.hasError) {
              return Text(
                  "Error fetching data1 ${snapshot.error} ${snapshot.error.runtimeType}");
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}

class EpisodeBio extends StatelessWidget {
  final Episode episode;
  EpisodeBio({
    Key key,
    @required this.episode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(episode.name),
        ),
        body: Column(
          children: <Widget>[
            ListView(padding: const EdgeInsets.all(8.0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), children: <Widget>[

              new ListTile(
                  leading: Icon(Icons.tv), title: Text(" ${episode.name}")),
              new ListTile(
                  leading: Icon(Icons.live_tv),
                  title: Text("${episode.episode}")),
              new ListTile(
                  leading: Icon(Icons.date_range),
                  title: Text(" ${episode.airDate}")),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Characters",
                    style: Theme.of(context).textTheme.title,
                  ))
            ]),
    Expanded( child: FutureBuilder(
                future: Character.getListOfCharacters(episode.characters),
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
