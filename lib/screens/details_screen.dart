import 'package:flutter/material.dart';
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
            return Center(child: Text('Ups, algo falló: \${snapshot.error}', style: const TextStyle(color: Colors.white)));
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
                  height: 300,
                  child: Image.network(bannerUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 0, left: 0, right: 0,
                  height: 300,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF0F172A), 
                          const Color(0xFF0F172A).withOpacity(0.3), 
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SafeArea(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    
                    SizedBox(height: isDesktop ? 100 : 180),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: isDesktop 
                          ? _buildDesktopHeader(context, anime, dominantColor) 
                          : _buildMobileHeader(context, anime, dominantColor),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(child: _buildStatColumn(Icons.star_rounded, Colors.amber, '\${anime.averageScore ?? "?"}%', 'Puntuación')),
                              Expanded(child: _buildStatColumn(Icons.tv_rounded, Colors.blueAccent, '\${anime.episodes ?? "?"}', 'Episodios')),
                              Expanded(child: _buildStatColumn(Icons.info_outline_rounded, Colors.greenAccent, anime.status ?? '???', 'Estado')),
                            ],
                          ),
                          const SizedBox(height: 32),

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

                          const Text('Sinopsis', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            cleanDesc,
                            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                            textAlign: TextAlign.justify,
                          ),
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

  Widget _buildDesktopHeader(BuildContext context, Anime anime, Color dominantColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 70), // Tu super margen de 70px
          width: 140,
          height: 210,
          decoration: _posterDecoration(dominantColor),
          child: _posterImage(anime.coverImage),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              Text(
                anime.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, height: 1.2),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, // Restaurado al ancho completo para que no se vea cortado
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
            height: 240, // La portada resalta más en celular al ser el foco principal
            decoration: _posterDecoration(dominantColor),
            child: _posterImage(anime.coverImage),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          anime.title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, height: 1.2),
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
                SnackBar(content: Text('Error: \$e'), backgroundColor: Colors.redAccent)
              );
            }
          },
          icon: Icon(isFavorite ? Icons.bookmark_added_rounded : Icons.bookmark_add_rounded, size: 20),
          label: Text(
            isFavorite ? 'En Mi Lista' : 'Añadir a Mi Lista', 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
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
          style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
