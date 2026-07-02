import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/anime_model.dart';
import '../services/anilist_service.dart';
import '../services/firebase_service.dart';

class DetailsScreen extends StatelessWidget {
  final int idMal;
  final String initialHexColor;

  const DetailsScreen({super.key, required this.idMal, required this.initialHexColor});

  Color _hexToColor(String code) {
    if (code.isEmpty || !code.startsWith('#')) return Colors.deepPurple;
    try {
      return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultColor = _hexToColor(initialHexColor);
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: FutureBuilder<Anime>(
        future: AniListService.getAnimeDetails(idMal),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: defaultColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Ups, algo falló: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          final anime = snapshot.data!;
          final dominantColor = _hexToColor(anime.hexColor);
          final bannerUrl = anime.bannerImage ?? anime.coverImage;
          final cleanDesc = anime.description?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '') ?? 'Sin sinopsis disponible.';

          return SingleChildScrollView(
            child: Stack(
              children: [
                Positioned(
                  top: 0, left: 0, right: 0,
                  height: 320,
                  child: Image.network(bannerUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 0, left: 0, right: 0,
                  height: 322,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF0F172A), 
                          const Color(0xFF0F172A).withOpacity(0.8), 
                          Colors.transparent
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: isDesktop ? 100 : 180),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: isDesktop 
                          ? _buildDesktopHeader(context, anime, dominantColor) 
                          : _buildMobileHeader(context, anime, dominantColor),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ESTADÍSTICAS PRINCIPALES LIMPIAS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(child: _buildStatColumn(Icons.star_rounded, Colors.amber, '${anime.averageScore ?? "?"}%', 'Puntuación')),
                              Expanded(child: _buildStatColumn(Icons.tv_rounded, Colors.blueAccent, '${anime.episodes ?? "?"}', 'Episodios')),
                              Expanded(child: _buildStatColumn(Icons.info_outline_rounded, Colors.greenAccent, anime.status ?? '???', 'Estado')),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // TEMPORIZADOR
                          if (anime.nextEpisodeTime != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: dominantColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: dominantColor.withOpacity(0.5)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.timer, color: Colors.white70),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Próximo episodio en ${_formatTimeUntil(anime.nextEpisodeTime!)}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),

                          // GÉNEROS
                          if (anime.genres != null && anime.genres!.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: anime.genres!.map((genre) => Chip(
                                label: Text(genre, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                backgroundColor: dominantColor.withOpacity(0.2),
                                side: BorderSide(color: dominantColor.withOpacity(0.5), width: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              )).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // REPRODUCTOR DE TRÁILER INTEGRADO
                          if (anime.trailerId != null) ...[
                            const Text('Tráiler', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _TrailerPlayer(trailerId: anime.trailerId!),
                            const SizedBox(height: 32),
                          ],

                          // SINOPSIS
                          const Text('Sinopsis', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            cleanDesc,
                            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 32),

                          // FICHA TÉCNICA
                          const Text('Ficha Técnica', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildInfoChip(Icons.video_library_rounded, anime.format ?? 'Desconocido'),
                              if (anime.seasonYear != null)
                                _buildInfoChip(Icons.calendar_month_rounded, '${anime.season ?? ""} ${anime.seasonYear}'),
                              if (anime.studio != null) 
                                _buildInfoChip(Icons.business_rounded, anime.studio!),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // PERSONAJES
                          if (anime.characters != null && anime.characters!.isNotEmpty) ...[
                            const Text('Personajes Principales', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 160,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: anime.characters!.length,
                                itemBuilder: (context, index) {
                                  final char = anime.characters![index];
                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: Image.network(
                                            char['image']!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 80, height: 80, color: Colors.grey.shade800,
                                              child: const Icon(Icons.person, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          char['name']!,
                                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // CRONOLOGÍA / RELACIONES
                          if (anime.relations != null && anime.relations!.isNotEmpty) ...[
                            const Text('Animes Relacionados', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 250,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: anime.relations!.length,
                                itemBuilder: (context, index) {
                                  final rel = anime.relations![index];
                                  final type = rel['relationType'];
                                  final label = _translateRelationType(type);
                                  
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailsScreen(
                                            idMal: rel['idMal'],
                                            initialHexColor: rel['hexColor'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 120,
                                      margin: const EdgeInsets.only(right: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              rel['coverImage']!,
                                              width: 120,
                                              height: 160,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 120, height: 160, color: Colors.grey.shade800,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: dominantColor,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            rel['title']!,
                                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 60), 
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimeUntil(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    if (days > 0) return '$days días y $hours hrs';
    return '$hours horas';
  }

  String _translateRelationType(String type) {
    switch (type) {
      case 'PREQUEL': return 'PRECUELA';
      case 'SEQUEL': return 'SECUELA';
      case 'SIDE_STORY': return 'HISTORIA ALTERNA';
      case 'SPIN_OFF': return 'SPIN-OFF';
      case 'ALTERNATIVE': return 'VERSIÓN ALTERNA';
      case 'PARENT': return 'HISTORIA PRINCIPAL';
      case 'SUMMARY': return 'RESUMEN';
      case 'CHARACTER': return 'PERSONAJE';
      default: return 'RELACIONADO';
    }
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, Anime anime, Color dominantColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 70),
          width: 160,
          height: 240,
          decoration: _posterDecoration(dominantColor),
          child: _posterImage(anime.coverImage),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                anime.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32, height: 1.1),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _buildAddButton(context, anime.idMal, dominantColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context, Anime anime, Color dominantColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: 160,
            height: 240,
            decoration: _posterDecoration(dominantColor),
            child: _posterImage(anime.coverImage),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          anime.title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, height: 1.2),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: _buildAddButton(context, anime.idMal, dominantColor),
        ),
      ],
    );
  }

  BoxDecoration _posterDecoration(Color color) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 8))],
    );
  }

  Widget _posterImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(url, fit: BoxFit.cover),
    );
  }

  Widget _buildAddButton(BuildContext context, int idMal, Color color) {
    return StreamBuilder<bool>(
      stream: FirebaseService.isFavoriteStream(idMal),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        
        return ElevatedButton.icon(
          onPressed: () async {
            if (FirebaseService.currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ve a la pestaña Perfil para iniciar sesión.'),
                  backgroundColor: Colors.redAccent,
                )
              );
              return;
            }
            try {
              if (isFavorite) {
                await FirebaseService.removeFavorite(idMal);
              } else {
                await FirebaseService.addFavorite(idMal);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent)
              );
            }
          },
          icon: Icon(isFavorite ? Icons.bookmark_added_rounded : Icons.bookmark_add_rounded, size: 22),
          label: Text(
            isFavorite ? 'En Mi Lista' : 'Añadir a Mi Lista', 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFavorite ? Colors.green.shade600 : color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    );
  }

  Widget _buildStatColumn(IconData icon, Color iconColor, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label, 
          style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ==========================================
// WIDGET REPRODUCTOR DE YOUTUBE
// ==========================================
class _TrailerPlayer extends StatefulWidget {
  final String trailerId;
  const _TrailerPlayer({required this.trailerId});

  @override
  State<_TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<_TrailerPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.trailerId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: _controller,
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
