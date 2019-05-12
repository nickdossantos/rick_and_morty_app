import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'character.dart';

class Episode {
  static String locationsEndpoint =
      "https://rickandmortyapi.com/api/episode?page=1";
  final int id;
  final String name;
  final String airDate;
  final String episode;
  final List<dynamic> characters;
  final String created;

  Episode(
      {this.id,
        this.name,
        this.airDate,
        this.episode,
        this.characters,
        this.created,
        });

  static Future<List<Episode>> fetchEpisodes() async {
    final response = await http.get(locationsEndpoint);
    if (response.statusCode == 200) {
      List<Episode> characters = [];
      final items = json.decode(response.body)['results'];
      for (Map item in items) {
        characters.add(Episode(
          id: item["id"],
          name: item["name"],
          airDate: item["air_date"],
          episode: item["episode"],
          characters: item["characters"],
          created: item["created"],
        ));
      }
      return characters;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  static getEpisodesFromString(String episodes){
    List<Episode> listOfEpisodes;
    final listOfOriginalEp = json.decode(episodes);
    for (Map item in listOfOriginalEp){
      print(item["characters"]);
      listOfEpisodes.add(Episode(
        id: item["id"],
        name: item["name"],
        airDate: item["air_date"],
        episode: item["episode"],
        //characters: Character.getCharactersFromString(item["characters"]),
        created: item["created"],
      ));
    }
    return listOfEpisodes;
  }
}
