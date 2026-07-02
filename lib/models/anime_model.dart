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
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    List<String>? parsedGenres;
    if (json['genres'] != null) {
      parsedGenres = List<String>.from(json['genres']);
    }

    return Anime(
      idMal: json['idMal'] ?? 0,
      title: json['title']['romaji'] ?? 'Título desconocido',
      coverImage: json['coverImage']['large'] ?? '',
      bannerImage: json['bannerImage'],
      hexColor: json['coverImage']['color'] ?? '#311b92', // Morado oscuro por defecto
      description: json['description'],
      genres: parsedGenres,
      episodes: json['episodes'],
      status: json['status'],
      averageScore: json['averageScore'],
    );
  }
}
