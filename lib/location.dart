import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Location {
  static String locationsEndpoint =
      "https://rickandmortyapi.com/api/location?page=";
  final int id;
  final String name;
  final String type;
  final String dimension;
  final List<dynamic> characters;
  final String created;

  Location(
      {this.id,
      this.name,
      this.type,
      this.dimension,
      this.characters,
      this.created});

  static Future<List<Location>> fetchAllLocations() async {
    final page = 1;
    final response = await http.get(locationsEndpoint + page.toString());

    if (response.statusCode == 200) {
      List<Location> characters = [];
      final items = json.decode(response.body)['results'];
      for (Map item in items) {
        characters.add(Location(
          id: item["id"],
          name: item["name"],
          type: item["type"],
          dimension: item["dimension"],
          characters: item["residents"],
          created: item["created"],
        ));
      }
      return characters;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }
}
