import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final query = '''
    query {
      Media(idMal: 40748, type: ANIME) { # Jujutsu Kaisen
        relations {
          edges {
            relationType
            node {
              idMal
              title { romaji }
              coverImage { large }
              type
            }
          }
        }
      }
    }
  ''';
  final response = await http.post(
    Uri.parse('https://graphql.anilist.co'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'query': query}),
  );
  print(response.body);
}
