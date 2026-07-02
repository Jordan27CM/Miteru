import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final response = await http.get(Uri.parse('https://api.jikan.moe/v4/anime?q=juju&limit=5'));
  final data = json.decode(response.body);
  for (var anime in data['data']) {
    print(anime['title']);
  }
}
