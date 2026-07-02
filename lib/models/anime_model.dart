class Anime {
  final int idMal;
  final String title;
  final String coverImage;
  final String? bannerImage;
  final String hexColor;
  
  final String? description;
  final List<String>? genres;
  final int? episodes;
  final String? status;
  final int? averageScore;
  
  // Nuevos campos
  final String? format;
  final String? season;
  final int? seasonYear;
  final String? studio;
  final String? trailerId;
  final int? nextEpisodeTime;
  final List<Map<String, String>>? characters;
  final List<Map<String, dynamic>>? relations;

  Anime({
    required this.idMal,
    required this.title,
    required this.coverImage,
    this.bannerImage,
    required this.hexColor,
    this.description,
    this.genres,
    this.episodes,
    this.status,
    this.averageScore,
    this.format,
    this.season,
    this.seasonYear,
    this.studio,
    this.trailerId,
    this.nextEpisodeTime,
    this.characters,
    this.relations,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    List<String>? parsedGenres;
    if (json['genres'] != null) {
      parsedGenres = List<String>.from(json['genres']);
    }

    // Extraer estudio principal si existe
    String? mainStudio;
    if (json['studios'] != null && json['studios']['nodes'] != null && (json['studios']['nodes'] as List).isNotEmpty) {
      final studioNode = (json['studios']['nodes'] as List).first;
      mainStudio = studioNode['name'];
    }

    // Extraer personajes
    List<Map<String, String>>? parsedCharacters;
    if (json['characters'] != null && json['characters']['edges'] != null) {
      parsedCharacters = [];
      for (var edge in json['characters']['edges']) {
        final node = edge['node'];
        if (node != null) {
          parsedCharacters.add({
            'name': node['name']['full'] ?? 'Desconocido',
            'image': node['image']['large'] ?? '',
          });
        }
      }
    }

    // Extraer relaciones (solo animes con ID)
    List<Map<String, dynamic>>? parsedRelations;
    if (json['relations'] != null && json['relations']['edges'] != null) {
      parsedRelations = [];
      for (var edge in json['relations']['edges']) {
        final node = edge['node'];
        if (node != null && node['type'] == 'ANIME' && node['idMal'] != null) {
          parsedRelations.add({
            'idMal': node['idMal'],
            'title': node['title']?['romaji'] ?? 'Desconocido',
            'coverImage': node['coverImage']?['large'] ?? '',
            'hexColor': node['coverImage']?['color'] ?? '#311b92',
            'relationType': edge['relationType'] ?? 'RELATED',
          });
        }
      }
    }

    return Anime(
      idMal: json['idMal'] ?? 0,
      title: json['title']['romaji'] ?? 'Título desconocido',
      coverImage: json['coverImage']['large'] ?? '',
      bannerImage: json['bannerImage'],
      hexColor: json['coverImage']['color'] ?? '#311b92',
      description: json['description'],
      genres: parsedGenres,
      episodes: json['episodes'],
      status: json['status'],
      averageScore: json['averageScore'],
      format: json['format'],
      season: json['season'],
      seasonYear: json['seasonYear'],
      studio: mainStudio,
      trailerId: (json['trailer'] != null && json['trailer']['site'] == 'youtube') ? json['trailer']['id'] : null,
      nextEpisodeTime: json['nextAiringEpisode']?['timeUntilAiring'],
      characters: parsedCharacters,
      relations: parsedRelations,
    );
  }
}
