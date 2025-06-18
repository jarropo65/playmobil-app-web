// lib/game_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'; // Necessary for shuffling

import 'achievements.dart';
import 'currency_manager.dart';
import 'screens/achievements_screen.dart'; // Ensure this path is correct if used

enum Difficulty { easy, hard } // Translated enum values

// New class for card content
class CardContent {
  final String imagePath;
  final int
      pairId; // To identify pairs (e.g., skirt.png and text_skirt.png have the same pairId)

  CardContent({required this.imagePath, required this.pairId});
}

class GameScreen extends StatefulWidget {
  final String usuario;
  const GameScreen({super.key, required this.usuario});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Difficulty _difficulty = Difficulty.easy; // Default theme
  String _currentTheme = 'clothing_items'; // Default theme, translated
  int gridSize = 16;
  bool _isProcessing = false;

  int puntuacion = 0;
  List<int> mejoresPuntuaciones = [];

  // Updated themes map to use images from the 'memory_game' folder
  final Map<String, List<Map<String, String>>> themes = {
    'clothing_items': [ // Translated 'prendas_vestir'
      {
        'objectImage': 'assets/images/memory_game/belt.png',
        'textImage': 'assets/images/memory_game/texto_belt.png',
      },
      {
        'objectImage': 'assets/images/memory_game/blouse.png',
        'textImage': 'assets/images/memory_game/texto_blouse.png',
      },
      {
        'objectImage': 'assets/images/memory_game/bracelet.png',
        'textImage': 'assets/images/memory_game/texto_bracelet.png',
      },
      {
        'objectImage': 'assets/images/memory_game/dress.png',
        'textImage': 'assets/images/memory_game/texto_dress.png',
      },
      {
        // CORRECTED: The path for gloves.png was broken across two lines.
        // It has been fixed to be a single string.
        'objectImage': 'assets/images/memory_game/gloves.png',
        'textImage': 'assets/images/memory_game/texto_gloves.png',
      },
      {
        'objectImage': 'assets/images/memory_game/hat.png',
        'textImage': 'assets/images/memory_game/texto_hat.png',
      },
      {
        'objectImage': 'assets/images/memory_game/jeans.png',
        'textImage': 'assets/images/memory_game/texto_jeans.png',
      },
      {
        'objectImage': 'assets/images/memory_game/jumper.png',
        'textImage': 'assets/images/memory_game/texto_jumper.png',
      },
      {
        'objectImage': 'assets/images/memory_game/necklace.png',
        'textImage': 'assets/images/memory_game/texto_necklace.png',
      },
      {
        'objectImage': 'assets/images/memory_game/raincoat.png',
        'textImage': 'assets/images/memory_game/texto_raincoat.png',
      },
      {
        'objectImage': 'assets/images/memory_game/ring.png',
        'textImage': 'assets/images/memory_game/texto_ring.png',
      },
      {
        'objectImage': 'assets/images/memory_game/scarf.png',
        'textImage': 'assets/images/memory_game/texto_scarf.png',
      },
      {
        'objectImage': 'assets/images/memory_game/shirt.png',
        'textImage': 'assets/images/memory_game/texto_shirt.png',
      },
      {
        'objectImage': 'assets/images/memory_game/shoes.png',
        'textImage': 'assets/images/memory_game/texto_shoes.png',
      },
      {
        'objectImage': 'assets/images/memory_game/skirt.png',
        'textImage': 'assets/images/memory_game/texto_skirt.png',
      },
      {
        'objectImage': 'assets/images/memory_game/slippers.png',
        'textImage': 'assets/images/memory_game/texto_slippers.png',
      },
      {
        'objectImage': 'assets/images/memory_game/sunglasses.png',
        'textImage': 'assets/images/memory_game/texto_sunglasses.png',
      },
      {
        'objectImage': 'assets/images/memory_game/trainers.png',
        'textImage': 'assets/images/memory_game/texto_trainers.png',
      },
    ],
  };

  late List<CardContent> cardContents;
  late List<bool> cardRevealed;
  late List<bool> cardMatched;
  int? firstCardIndex;
  int movimientos = 0;
  int parejasEncontradas = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  // --- _initializeGame FUNCTION MODIFIED ---
  Future<void> _initializeGame() async {
    setState(() {
      switch (_difficulty) {
        case Difficulty.easy: // Translated: 'facil'
          gridSize = 16; // 8 pairs (4x4)
          break;
        case Difficulty.hard: // Translated: 'dificil'
          gridSize = 36; // 18 pairs (6x6)
          break;
      }

      List<Map<String, String>> availablePairs = List.from(
        themes[_currentTheme]!,
      );
      availablePairs.shuffle(Random()); // Shuffle available pairs

      List<Map<String, String>> selectedImagePairs =
          availablePairs.take(gridSize ~/ 2).toList();

      cardContents = [];
      int currentPairId = 0;
      for (var pair in selectedImagePairs) {
        cardContents.add(
          CardContent(imagePath: pair['objectImage']!, pairId: currentPairId),
        );
        cardContents.add(
          CardContent(imagePath: pair['textImage']!, pairId: currentPairId),
        );
        currentPairId++;
      }
      cardContents.shuffle(Random()); // Shuffle all cards

      cardRevealed = List.generate(gridSize, (index) => false);
      cardMatched = List.generate(gridSize, (index) => false);
      firstCardIndex = null;
      movimientos = 0;
      parejasEncontradas = 0;
      _isProcessing = false;
    });

    // Load best scores for the current difficulty and user
    await _cargarMejoresPuntuaciones();
  }

  void _calcularPuntuacion() {
    int puntosDificultad;
    switch (_difficulty) {
      case Difficulty.easy: // Translated
        puntosDificultad = 100;
        break;
      case Difficulty.hard: // Translated
        puntosDificultad = 300;
        break;
    }
    puntuacion = puntosDificultad - (movimientos * 2);
    if (puntuacion < 0) puntuacion = 0;
  }

  // --- _guardarPuntuacion FUNCTION MODIFIED ---
  // Now uses CurrencyManager.guardarPuntuacion with all arguments
  Future<void> _guardarPuntuacion(int puntuacion) async {
    String gameNameIdentifier = 'memoria'; // 'memoria' is an internal game ID
    String difficultyString = _difficulty.name; // 'easy' or 'hard'

    await CurrencyManager.guardarPuntuacion(
      gameNameIdentifier,
      puntuacion,
      widget.usuario,
      difficultyString,
    );

    await _cargarMejoresPuntuaciones(); // Update UI with the new saved score
  }

  // --- _cargarMejoresPuntuaciones FUNCTION MODIFIED ---
  // Now uses CurrencyManager.obtenerLasCincoMejoresPuntuacionesPorJuego
  Future<void> _cargarMejoresPuntuaciones() async {
    if (!mounted) return;
    String gameNameIdentifier = 'memoria'; // 'memoria' is an internal game ID
    // We don't need difficulty here if `obtenerLasCincoMejoresPuntuacionesPorJuego` consolidates
    // However, if you want to keep them by difficulty on this screen, you can use
    // String difficultyString = _difficulty.name; // 'easy' or 'hard'

    // KEY CHANGE: Function name adjusted to the correct one in CurrencyManager
    List<int> loadedScores =
        await CurrencyManager.obtenerLasCincoMejoresPuntuacionesPorJuego(
      widget.usuario,
      gameNameIdentifier,
      // Do not pass difficultyString here if the consolidated function does not require it
    );

    setState(() {
      mejoresPuntuaciones = loadedScores;
      // They should already come sorted from CurrencyManager, but re-sort to ensure
      mejoresPuntuaciones.sort((b, a) => a.compareTo(b));
    });
  }

  void _handleCardTap(int index) {
    if (cardMatched[index] || cardRevealed[index] || _isProcessing) return;

    if (!mounted) return;
    setState(() {
      cardRevealed[index] = true;

      if (firstCardIndex == null) {
        firstCardIndex = index;
      } else {
        // Prevent selecting the same card twice
        if (firstCardIndex == index) return;

        _isProcessing = true;
        movimientos++;

        if (cardContents[firstCardIndex!].pairId ==
            cardContents[index].pairId) {
          // It's a match
          cardMatched[firstCardIndex!] = true; // CORRECTED HERE
          cardMatched[index] = true;
          parejasEncontradas++;
          firstCardIndex = null;
          _isProcessing = false;

          if (parejasEncontradas == gridSize ~/ 2) {
            _showGameOverDialog();
          }
        } else {
          // Not a match
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() {
                cardRevealed[firstCardIndex!] = false;
                cardRevealed[index] = false;
                firstCardIndex = null;
                _isProcessing = false;
              });
            }
          });
        }
      }
    });
  }

  void _showGameOverDialog() async {
    _calcularPuntuacion();
    await _guardarPuntuacion(puntuacion); // This function already uses the new CurrencyManager

    int monedasGanadas = CurrencyManager.calcularRecompensa(
      _difficulty.name,
      puntuacion,
    );
    // addMonedas now requires the user
    await CurrencyManager.addMonedas(monedasGanadas, widget.usuario);

    String dificultadStr = _difficulty.toString().split('.').last;
    // --- KEY CORRECTION HERE ---
    await AchievementManager.verificarLogros(
      widget.usuario, // The first argument is the user
      'memoria', // The second argument is the gameNameIdentifier
      dificultadStr, // The third argument is the difficulty
      puntuacion, // The fourth argument is the score
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'), // Translated
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You completed the ${_difficulty.name} level'), // Translated
              Text('Moves: $movimientos'), // Translated
              Text('Score: $puntuacion'), // Translated
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('Coins earned: $monedasGanadas'), // Translated
                ],
              ),
              const SizedBox(height: 16),
              const Text('Best Scores:'), // Translated
              ...mejoresPuntuaciones
                  .take(5)
                  .map((p) => Text('$p points')) // Translated
                  .toList(),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Back to menu'), // Translated
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
            TextButton(
              child: const Text('Play again'), // Translated
              onPressed: () {
                Navigator.of(context).pop();
                _initializeGame();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(int index) {
    return GestureDetector(
      onTap: () => _handleCardTap(index),
      child: Card(
        elevation: cardRevealed[index] || cardMatched[index] ? 10 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: cardMatched[index]
                ? Colors.green.withOpacity(0.5)
                : cardRevealed[index]
                    ? Colors.blue.withOpacity(0.3)
                    : Colors.grey[300],
          ),
          child: Center(
            child: cardRevealed[index] || cardMatched[index]
                ? Padding(
                    padding: const EdgeInsets.all(
                      4.0,
                    ), // Reduced for more space for the image
                    child: Image.asset(
                      cardContents[index].imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint(
                          'Error loading image: ${cardContents[index].imagePath}, Error: $error', // Translated
                        ); // Use debugPrint
                        return const Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.red,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.question_mark,
                    size: 50,
                    color: Colors.black54,
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definimos las variables aquí para que LayoutBuilder pueda calcularlas
    // y el resto del widget las use.
    // Esto es un placeholder; los valores reales se calcularán dentro de LayoutBuilder.
    int currentCrossAxisCount = 4; // Default para Easy, se ajustará dinámicamente
    double currentAspectRatio = 0.85; // Default, se ajustará dinámicamente

    // Reemplazamos el switch estático con LayoutBuilder para una adaptación dinámica
    return Scaffold(
      appBar: AppBar(
        // EXPLICITLY PLACE THE BACK ARROW
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        // DISABLE AUTOMATIC DRAWER BUTTON GENERATION
        automaticallyImplyLeading: false,
        title: const Text('Memory Game'), // Translated
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // THIS IS THE ONLY MENU BUTTON FOR THE DRAWER
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          // Other icons in the AppBar
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AchievementsScreen(usuario: widget.usuario),
                ),
              );
            },
          ),
          FutureBuilder<int>(
            future: CurrencyManager.getMonedas(widget.usuario),
            builder: (context, snapshot) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${snapshot.data ?? 0}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Moves: $movimientos', // Translated
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Game Options', // Translated
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ExpansionTile(
              title: const Text('Difficulty'), // Translated
              leading: const Icon(Icons.settings_accessibility),
              children: <Widget>[
                RadioListTile<Difficulty>(
                  title: const Text('Beginners (4x4)'), // Translated
                  value: Difficulty.easy, // Changed from .facil
                  groupValue: _difficulty,
                  onChanged: (Difficulty? value) {
                    if (value != null) {
                      setState(() {
                        _difficulty = value;
                        _initializeGame(); // This already loads the best scores
                      });
                      Navigator.pop(context); // Close the drawer
                    }
                  },
                ),
                RadioListTile<Difficulty>(
                  title: const Text('Advanced (6x6)'), // Translated
                  value: Difficulty.hard, // Changed from .dificil
                  groupValue: _difficulty,
                  onChanged: (Difficulty? value) {
                    if (value != null) {
                      setState(() {
                        _difficulty = value;
                        _initializeGame(); // This already loads the best scores
                      });
                      Navigator.pop(context); // Close the drawer
                    }
                  },
                ),
              ],
            ),
            // You can add more options to the Drawer here if needed
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder( // Usamos LayoutBuilder para el control responsivo
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            
            // Lógica para crossAxisCount basada en el ancho de la pantalla y la dificultad
            if (_difficulty == Difficulty.easy) {
              if (screenWidth > 1000) {
                currentCrossAxisCount = 8; // Ej: 8 columnas para escritorio muy ancho
              } else if (screenWidth > 700) {
                currentCrossAxisCount = 6; // Ej: 6 columnas para tabletas o escritorios medianos
              } else if (screenWidth > 400) {
                currentCrossAxisCount = 4; // 4 columnas para móviles más anchos
              } else {
                currentCrossAxisCount = 3; // 3 columnas para móviles muy estrechos
              }
            } else { // Difficulty.hard
              if (screenWidth > 1200) {
                currentCrossAxisCount = 10; // Ej: 10 columnas para escritorio muy ancho
              } else if (screenWidth > 900) {
                currentCrossAxisCount = 8; // Ej: 8 columnas para tabletas o escritorios medianos
              } else if (screenWidth > 600) {
                currentCrossAxisCount = 6; // 6 columnas para tabletas más pequeñas o móviles anchos
              } else {
                currentCrossAxisCount = 4; // 4 columnas para móviles
              }
            }

            // Lógica para aspectRatio basada en el ancho de la pantalla
            // Generalmente, un aspecto de 1.0 (cuadrado) es buen punto de partida.
            // Para tarjetas que contienen imágenes y texto, a veces un aspecto ligeramente
            // más alto (ej. 0.9) es mejor para dar más altura al contenido.
            if (screenWidth < 600) { // Móviles
              currentAspectRatio = 0.9;
            } else if (screenWidth < 900) { // Tabletas
              currentAspectRatio = 1.0;
            } else { // Escritorio
              currentAspectRatio = 1.1;
            }


            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: const [
                      Text(
                        'Find the pairs!', // Translated
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap the cards to flip them and find all the image pairs.', // Translated
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(
                      8.0,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: currentCrossAxisCount, // Usamos la variable dinámica
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: currentAspectRatio, // Usamos la variable dinámica
                    ),
                    itemCount: gridSize,
                    itemBuilder: (context, index) {
                      return _buildCard(index);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
