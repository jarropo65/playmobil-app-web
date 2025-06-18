import 'package:flutter/material.dart';
import 'comic_game_screen.dart';
import '../word_search_game.dart';
import '../game_screen.dart'; // This is likely the Memory Game screen
import '../puzzle_game.dart';
import '../word_game.dart';
import '../screens/reading_comprehension_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  final String usuario;
  const GameSelectionScreen({Key? key, required this.usuario}) : super(key: key);

  // Definimos una lista de los datos de cada juego para un ListView.builder
  List<Map<String, dynamic>> get _gameItems => [
    {
      'title': 'Memory Game',
      'icon': Icons.memory,
      'color': Colors.purple,
      'screen': (BuildContext context) => GameScreen(usuario: usuario),
    },
    {
      'title': 'Puzzle',
      'icon': Icons.extension,
      'color': Colors.orange,
      'screen': (BuildContext context) => PuzzleGame(usuario: usuario),
    },
    {
      'title': 'Comic Game',
      'icon': Icons.book,
      'color': Colors.pink,
      'screen': (BuildContext context) => ComicGameScreen(usuario: usuario),
    },
    {
      'title': 'Word Search',
      'icon': Icons.search,
      'color': Colors.green,
      'screen': (BuildContext context) => WordSearchGame(usuario: usuario),
    },
    {
      'title': 'Word Game',
      'icon': Icons.abc,
      'color': Colors.blue,
      'screen': (BuildContext context) => WordGame(usuario: usuario),
    },
    {
      'title': 'Reading Comprehension',
      'icon': Icons.menu_book,
      'color': Colors.teal,
      'screen': (BuildContext context) => ReadingComprehensionScreen(usuario: usuario),
    },
  ];

  // A helper method to build game list items
  Widget _buildGameMenuItem(
      BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Space between items
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white.withOpacity(0.85), // A nearly opaque, slightly transparent white
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          // ¡CAMBIO CLAVE AQUÍ! Reemplazamos Flexible con un Row para dar espacio al texto.
          title: Row( // Usamos un Row para controlar la disposición del texto
            children: [
              Expanded( // Expanded permite que el texto ocupe el espacio disponible
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Forzamos el color del texto a negro para máxima visibilidad
                  ),
                  // Eliminamos overflow y maxLines por ahora para depurar
                  // Si el texto se corta, podemos reintroducirlos con un FittedBox
                ),
              ),
            ],
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Adventure!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white), // Ensure icons are white for visibility
      ),
      body: Container(
        // The background container should take full available space
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/playmobil_juegos_fondo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column( // Use a main Column to structure layout
          children: [
            Expanded( // This Expanded ensures the ListView takes all remaining vertical space
              child: ListView.builder( // We use ListView.builder for more control
                padding: const EdgeInsets.all(16.0), // Apply padding to the ListView itself
                itemCount: _gameItems.length,
                itemBuilder: (context, index) {
                  final item = _gameItems[index];
                  return _buildGameMenuItem(
                    context,
                    item['title'],
                    item['icon'],
                    item['color'],
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (screenContext) => item['screen'](screenContext),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
