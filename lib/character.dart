import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'episode.dart';

class Character {
  static String charactersEndpoint =
      "https://rickandmortyapi.com/api/character/?page=";
  static String characterURLWithName =
      "https://rickandmortyapi.com/api/character/?name=";
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String origin;
  final String location;
  final String iconUrl;
  final List<Episode> episodes;
  final bool isSaved;

  Character(
      {this.id,
      this.name,
      this.status,
      this.species,
      this.gender,
      this.origin,
      this.location,
      this.iconUrl,
      this.episodes,
      this.isSaved});

  static Future<List<Character>> fetchAllWithName(String name) async {
    final response = await http.get(characterURLWithName + name);

    if (response.statusCode == 200) {
      List<Character> characters = [];
      final items = json.decode(response.body)['results'];
      for (Map item in items) {
        characters.add(Character(
          id: item["id"],
          name: item["name"],
          status: item["status"],
          species: item["species"],
          gender: item["gender"],
          origin: item["origin"]["name"],
          location: item["location"]["name"],
          iconUrl: item["image"],
          //episodes: Episode.getEpisodesFromString(item["episode"])
        ));
      }
      return characters;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  set isSaved(bool b){
    isSaved = b;
  }

  static List<Character> getCharactersFromString(var characters) {
    List<Character> listOfCharacters;
    final listOfResidents = json.decode(characters);
    for (Map item in listOfResidents) {
      listOfCharacters.add(Character(
          name: item["name"],
          id: item["id"],
          status: item["status"],
          species: item["species"],
          gender: item["gender"],
          origin: item["origin"]["name"],
          location: item["location"]["name"],
          iconUrl: item["image"]));
    }
    return listOfCharacters;
  }

  static Future<List<Character>> getListOfCharacters(List<dynamic> characters) async {
    List<Character> listOfCharacters = [];
    final listOfResidents = characters;
    for (String url in listOfResidents) {
      print(url);
      final response = await http.get(url.toString());
      if (response.statusCode == 200) {
        final item = json.decode(response.body);
        print(item);
        print(item['name']);
        listOfCharacters.add(Character(
          name: item["name"],
          id: item["id"],
          status: item["status"],
          species: item["species"],
          gender: item["gender"],
          origin: item["origin"]["name"],
          location: item["location"]["name"],
          iconUrl: item["image"],
          //episodes: Episode.getEpisodesFromString(item["episode"])
        ));
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    }
    return listOfCharacters;
  }
}
