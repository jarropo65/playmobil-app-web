import 'package:flutter/material.dart';
import 'package:playmobil_app/currency_manager.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class ScoresScreen extends StatefulWidget {
  final String usuario;
  const ScoresScreen({super.key, required this.usuario});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  Map<String, List<int>> puntuacionesPorJuego = {};

  int totalJuegosCompletados = 0;
  int puntuacionTotalAcumulada = 0;

  // Definition of each game's data. These 'id's must match CurrencyManager!
  final List<Map<String, dynamic>> _gameData = [
    {
      'title': 'Memory Game', // Translated
      'id': 'memoria',
      'icon': Icons.memory,
      'color': Colors.purple,
    },
    {
      'title': 'Puzzle', // Already English
      'id': 'puzzle',
      'icon': Icons.extension,
      'color': Colors.orange,
    },
    {
      'title': 'Word Search', // Translated
      'id': 'sopa_de_letras',
      'icon': Icons.search,
      'color': Colors.green,
    },
    {
      'title': 'Word Game', // Translated
      'id': 'word_game',
      'icon': Icons.abc,
      'color': Colors.blue,
    },
    {
      'title': 'Reading Comprehension', // Translated
      'id': 'comprension_lectora',
      'icon': Icons.menu_book,
      'color': Colors.teal,
    },
    {
      'title': 'Comic Game', // Translated
      'id': 'comic_game', // <--- CRITICAL KEY! MUST BE EXACTLY 'comic_game'
      'icon': Icons.book,
      'color': Colors.pink,
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarPuntuaciones();
  }

  Future<void> _cargarPuntuaciones() async {
    final currentUser = widget.usuario;
    debugPrint('ScoresScreen: Loading scores for user: "$currentUser"');

    final loadedTotalJuegosCompletados = await CurrencyManager.getJuegosCompletados(currentUser);
    final loadedPuntuacionTotalAcumulada = await CurrencyManager.getTotalPuntuacionAcumuladaUsuario(currentUser);

    Map<String, List<int>> nuevasPuntuacionesPorJuego = {};
    for (var gameData in _gameData) {
      final gameKey = gameData['id'] as String;
      final topScores = await CurrencyManager.obtenerLasCincoMejoresPuntuacionesPorJuego(
        currentUser,
        gameKey,
      );
      nuevasPuntuacionesPorJuego[gameKey] = topScores;
      debugPrint('ScoresScreen: Loaded individual scores for "$gameKey": $topScores');
    }

    if (mounted) {
      setState(() {
        totalJuegosCompletados = loadedTotalJuegosCompletados;
        puntuacionTotalAcumulada = loadedPuntuacionTotalAcumulada;
        puntuacionesPorJuego = nuevasPuntuacionesPorJuego;
        debugPrint('ScoresScreen: State updated. Total Games: $totalJuegosCompletados, Total Score: $puntuacionTotalAcumulada');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scores', // Translated
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/playmobil_salon_fama_fondo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Your Achievements!', // Translated
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Games\nCompleted!', // Translated
                            totalJuegosCompletados.toString(),
                            Icons.emoji_events,
                            Colors.amber,
                          ),
                          _buildStatCard(
                            'Total Score\nAccumulated!', // Translated
                            puntuacionTotalAcumulada.toString(),
                            Icons.star,
                            Colors.yellow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Text(
                  'Your Best Moments!', // Translated
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ..._gameData.map((gameData) {
                final String gameKey = gameData['id'] as String;
                final String gameDisplayName = gameData['title'] as String;
                final IconData gameIcon = gameData['icon'] as IconData;
                final Color gameColor = gameData['color'] as Color;

                final List<int> mejoresPuntuaciones = puntuacionesPorJuego[gameKey] ?? [];
                mejoresPuntuaciones.sort((b, a) => a.compareTo(b));
                
                debugPrint('ScoresScreen: Preparing UI for $gameDisplayName (key: $gameKey). Available scores: $mejoresPuntuaciones');

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      gameDisplayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: gameColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        gameIcon,
                        color: gameColor,
                        size: 30,
                      ),
                    ),
                    children: [
                      if (mejoresPuntuaciones.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No scores yet!\nTime to play! 🎮', // Translated
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: mejoresPuntuaciones.take(5).length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getMedalColor(index),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getMedalColor(
                                        index,
                                      ).withOpacity(0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _getMedalEmoji(index),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              title: Text(
                                '${mejoresPuntuaciones[index]} points!', // Translated
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey[300]!;
      case 2:
        return Colors.brown[300]!;
      default:
        return Colors.blue[100]!;
    }
  }

  String _getMedalEmoji(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '${index + 1}';
    }
  }
}
