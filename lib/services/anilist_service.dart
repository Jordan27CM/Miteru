import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import '../models/anime_model.dart';

class AniListService {
  static const String _url = 'https://graphql.anilist.co';

  static Future<List<Anime>> getTrendingAnime() async {
    const String query = '''
      query {
        Page(page: 1, perPage: 20) {
          media(type: ANIME, sort: TRENDING_DESC) {
            idMal
            title { romaji }
            coverImage { large color }
            bannerImage
          }
        }
      }
    ''';
    return _fetchAnimeList(query);
  }

  static Future<List<Anime>> getTopAiringAnime() async {
    const String query = '''
      query {
        Page(page: 1, perPage: 5) {
          media(type: ANIME, status: RELEASING, sort: POPULARITY_DESC) {
            idMal
            title { romaji }
            coverImage { large color }
            bannerImage
          }
        }
      }
    ''';
    return _fetchAnimeList(query);
  }

  static Future<List<Anime>> searchAnime(String search) async {
    final String query = '''
      query(\$search: String) {
        Page(page: 1, perPage: 20) {
          media(search: \$search, type: ANIME, sort: POPULARITY_DESC) {
            idMal
            title { romaji }
            coverImage { large color }
            bannerImage
            description
            genres
            episodes
            status
            averageScore
          }
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'query': query,
          'variables': {'search': search}
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List animeList = data['data']['Page']['media'];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Error HTTP: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo la conexión: \$e');
    }
  }

  static Future<List<Anime>> getAnimesByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final String query = '''
      query(\$ids: [Int]) {
        Page(page: 1, perPage: 50) {
          media(idMal_in: \$ids, type: ANIME) {
            idMal
            title { romaji }
            coverImage { large color }
            bannerImage
            description
            genres
            episodes
            status
            averageScore
          }
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'query': query,
          'variables': {'ids': ids}
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List animeList = data['data']['Page']['media'];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Error HTTP: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo la conexión: \$e');
    }
  }

  static Future<Anime> getAnimeDetails(int idMal) async {
    final String query = '''
      query {
        Media(idMal: $idMal, type: ANIME) {
          idMal
          title { romaji }
          coverImage { large color }
          bannerImage
          description
          genres
          episodes
          status
          averageScore
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final animeData = data['data']['Media'];
        
        if (animeData == null) {
          throw Exception('Anime no encontrado en AniList.');
        }

        if (animeData['description'] != null) {
          try {
            String cleanDesc = animeData['description'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
            final translator = GoogleTranslator();
            final translation = await translator.translate(cleanDesc, to: 'es');
            animeData['description'] = translation.text; // Reemplazamos con el texto en español
          } catch (e) {
          }
        }

        return Anime.fromJson(animeData);
      } else {
        throw Exception('Error HTTP: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo la conexión: \$e');
    }
  }

  static Future<List<Anime>> _fetchAnimeList(String query) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['data']['Page']['media'];
        return list.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Error al conectar con AniList: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo la conexión con el servidor: \$e');
    }
  }
}
