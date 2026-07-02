import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'my_list_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const MyListScreen(),
    const ProfileScreen(),
  ];

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.deepPurpleAccent, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.deepPurpleAccent.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Text(
          'MITERU',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fondo base
      
      appBar: AppBar(
        title: _buildLogo(),
        centerTitle: true, // Siempre centrado (Web y Celular)
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  backgroundColor: const Color(0xFF0B1121), // Un tono ligeramente más oscuro para contrastar
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                  unselectedIconTheme: const IconThemeData(color: Colors.white54),
                  useIndicator: true,
                  indicatorColor: Colors.deepPurpleAccent.withOpacity(0.4),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('Inicio'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search_rounded),
                      selectedIcon: Icon(Icons.search_rounded),
                      label: Text('Buscar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bookmark_border_rounded),
                      selectedIcon: Icon(Icons.bookmark_rounded),
                      label: Text('Mi Lista'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: Text('Perfil'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Colors.white12),
                
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            )
          : IndexedStack( 
              index: _currentIndex,
              children: _screens,
            ),
      
      bottomNavigationBar: isDesktop ? null : NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0F172A), 
          indicatorColor: Colors.deepPurpleAccent.withOpacity(0.3), 
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white54),
              selectedIcon: Icon(Icons.home_rounded, color: Colors.white),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded, color: Colors.white54),
              selectedIcon: Icon(Icons.search_rounded, color: Colors.white),
              label: 'Buscar',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded, color: Colors.white54),
              selectedIcon: Icon(Icons.bookmark_rounded, color: Colors.white),
              label: 'Mi Lista',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: Colors.white54),
              selectedIcon: Icon(Icons.person_rounded, color: Colors.white),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
