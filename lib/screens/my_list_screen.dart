import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/anime_model.dart';
import '../services/anilist_service.dart';
import '../services/firebase_service.dart';
import 'details_screen.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('Mi Lista', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
          }

          final user = snapshot.data;
          if (user == null) {
            return _buildGuestView();
          }

          return _buildListView();
        },
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark_outline_rounded, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          const Text('Inicia sesión para ver tus favoritos', style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usa el menú para ir a la pestaña Perfil.'))
              );
            },
            icon: const Icon(Icons.person),
            label: const Text('Ir al Perfil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListView() {
    return FutureBuilder<List<int>>(
      future: FirebaseService.getFavoriteIds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
        }
        
        final ids = snapshot.data ?? [];
        if (ids.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 80, color: Colors.white24),
                SizedBox(height: 16),
                Text('Aún no tienes animes guardados', style: TextStyle(color: Colors.white54, fontSize: 16)),
              ],
            ),
          );
        }

        return FutureBuilder<List<Anime>>(
          future: AniListService.getAnimesByIds(ids),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar: \${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }

            final animes = snapshot.data ?? [];
            int crossAxisCount = MediaQuery.of(context).size.width > 1000 
                ? 5 : (MediaQuery.of(context).size.width > 600 ? 4 : 2);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 16, bottom: 40),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: animes.length,
                itemBuilder: (context, index) {
                  final anime = animes[index];
                  final dominantColor = _hexToColor(anime.hexColor);
                  return _buildAnimeCard(context, anime, dominantColor);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimeCard(BuildContext context, Anime anime, Color dominantColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => DetailsScreen(idMal: anime.idMal, initialHexColor: anime.hexColor),
        )).then((_) {
          setState(() {});
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: dominantColor.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(anime.coverImage, fit: BoxFit.cover),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.95), Colors.black.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12, left: 12, right: 12,
                child: Text(
                  anime.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, height: 1.2,
                    shadows: [Shadow(offset: Offset(0, 2), blurRadius: 4.0, color: Colors.black)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
