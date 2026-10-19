import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/screens/conversation_list_page.dart';
import 'package:le_coin_symbolique_front/screens/home_page.dart';
import 'package:le_coin_symbolique_front/screens/favoris_page.dart';
import 'package:le_coin_symbolique_front/screens/add_annonce_page.dart';
import 'package:le_coin_symbolique_front/screens/profile_page.dart';
import 'package:le_coin_symbolique_front/screens/setting_page.dart';
import 'package:le_coin_symbolique_front/service/auth_service.dart';
import 'package:le_coin_symbolique_front/screens/login_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final AuthService authService = AuthService();
  bool _darkMode = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return HomePage();
      case 1:
        return FavorisPage();
      case 2:
        return AjoutPage();
      case 3:
        return ConversationListPage();
      case 4:
        return ProfilePage();
      default:
        return HomePage();
    }
  }

  void _toggleDarkMode() {
    setState(() {
      _darkMode = !_darkMode;
    });
  }

  Future<void> _deconnect() async {
    try {
      final bool result = await authService.logout();
      if (result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de la déconnexion'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MaterialApp(
      theme: _darkMode
          ? ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey[800],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
        ),
      )
          : ThemeData.light().copyWith(
        primaryColor: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logo.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
          ),
          title: const Center(
            child: Text("Le Coin Symbolique"),
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'settings') {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (_)=> SettingsPage()));
                } else if (value == 'dark_mode') {
                  _toggleDarkMode();
                } else if (value == 'logout') {
                  _deconnect();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Paramètres du compte'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'dark_mode',
                  child: ListTile(
                    leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                    title: Text(isDarkMode ? 'Mode clair' : 'Mode sombre'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _getCurrentPage(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Ajouter'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}