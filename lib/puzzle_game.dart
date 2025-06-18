// lib/puzzle_game.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_manager.dart';
import 'achievements.dart';
import 'screens/achievements_screen.dart'; // Ensure this import is correct

enum PuzzleDifficulty { easy, hard } // Translated enum values

class PuzzleGame extends StatefulWidget {
  final String usuario;
  const PuzzleGame({super.key, required this.usuario});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  PuzzleDifficulty _difficulty = PuzzleDifficulty.easy; // Translated: facil to easy
  late List<int> tiles;
  int gridSize = 3;
  int movimientos = 0;
  bool gameComplete = false;
  late Image puzzleImage;
  List<int> mejoresPuntuaciones = []; // Best puzzle scores
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeGame(); // Call initializeGame first to set difficulty and gridSize
  }

  // --- _initializeGame FUNCTION MODIFIED ---
  // Now async and calls _cargarMejoresPuntuaciones
  Future<void> _initializeGame() async {
    int imageToLoad = 1; // Default: loads puzzle1.png for easy

    switch (_difficulty) {
      case PuzzleDifficulty.easy: // Translated: facil
        gridSize = 3; // 3x3
        imageToLoad = 1; // For easy, use puzzle1.png
        break;
      case PuzzleDifficulty.hard: // Translated: dificil
        gridSize = 5; // 5x5
        imageToLoad = 2; // For hard, use puzzle2.png
        break;
    }

    await _loadImage(imageToLoad); // Call _loadImage with the correct index

    tiles = List.generate(gridSize * gridSize, (index) {
      final totalTiles = gridSize * gridSize;
      if (index == totalTiles - 1) {
        return 0; // The empty space (0) goes at the end in the solved state
      } else {
        return index + 1; // Numbered pieces from 1 to N-1
      }
    });

    int lastMove = -1;
    int moves = 200; // Number of random moves to shuffle

    while (moves > 0) {
      int emptyIndex = tiles.indexOf(0);
      List<int> possibleMoves = [];

      // Up
      if (emptyIndex >= gridSize) {
        possibleMoves.add(emptyIndex - gridSize);
      }
      // Down
      if (emptyIndex < tiles.length - gridSize) {
        possibleMoves.add(emptyIndex + gridSize);
      }
      // Left
      if (emptyIndex % gridSize != 0) {
        possibleMoves.add(emptyIndex - 1);
      }
      // Right
      if (emptyIndex % gridSize != gridSize - 1) {
        possibleMoves.add(emptyIndex + 1);
      }

      // Avoid undoing the last move
      if (lastMove != -1) {
        possibleMoves.remove(lastMove);
      }

      if (possibleMoves.isNotEmpty) {
        int moveIndex = possibleMoves[Random().nextInt(possibleMoves.length)];
        // Swap tiles
        tiles[emptyIndex] = tiles[moveIndex];
        tiles[moveIndex] = 0;
        lastMove = emptyIndex;
        moves--;
      }
    }

    if (mounted) {
      setState(() {
        movimientos = 0;
        gameComplete = false;
      });
    }

    // Load best scores for the current difficulty and user
    await _cargarMejoresPuntuaciones();
  }

  Future<void> _loadImage(int imageIndex) async {
    try {
      if (!mounted) return; // Ensure the widget is still mounted
      setState(() {
        puzzleImage = Image.asset(
          'assets/images/puzzle/puzzle$imageIndex.png', // Use the passed imageIndex
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image: assets/images/puzzle/puzzle$imageIndex.png, Error: $error'); // Translated
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  'Error loading image', // Translated
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          },
        );
      });
    } catch (e) {
      debugPrint('Error loading image: $e'); // Translated
    }
  }

  void _moveTile(int index) {
    if (gameComplete) return;

    final emptyIndex = tiles.indexOf(0);
    if (_canMove(index, emptyIndex)) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = 0;
        movimientos++;

        if (_checkWin()) {
          gameComplete = true;
          _showVictoryDialog();
        }
      });
    }
  }

  bool _canMove(int index, int emptyIndex) {
    if (index ~/ gridSize == emptyIndex ~/ gridSize) {
      return (index - emptyIndex).abs() == 1;
    }
    if (index % gridSize == emptyIndex % gridSize) {
      return (index - emptyIndex).abs() == gridSize;
    }
    return false;
  }

  bool _checkWin() {
    bool win = true;
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) {
        win = false;
        break;
      }
    }
    if (tiles.isNotEmpty && tiles.last != 0) {
      win = false;
    }

    if (win) {
      _timer?.cancel();
    }
    return win;
  }

  // --- _showVictoryDialog FUNCTION MODIFIED ---
  // Now uses CurrencyManager.guardarPuntuacion and addMonedas with the user and difficulty
  void _showVictoryDialog() async {
    int puntuacionBase = 800;
    double multiplicadorDificultad = 1.0;

    switch (_difficulty) {
      case PuzzleDifficulty.easy: // Translated: facil
        multiplicadorDificultad = 1.0;
        break;
      case PuzzleDifficulty.hard: // Translated: dificil
        multiplicadorDificultad = 2.0;
        break;
    }

    int puntuacionFinal =
        (puntuacionBase * multiplicadorDificultad - (movimientos * 5)).toInt();
    puntuacionFinal = puntuacionFinal.clamp(0, 9999).toInt();

    String gameNameIdentifier = 'puzzle'; // Internal game ID
    String difficultyString = _difficulty.name;

    // 1. Save individual score and update accumulated total
    await CurrencyManager.guardarPuntuacion(
      gameNameIdentifier,
      puntuacionFinal,
      widget.usuario,
      difficultyString,
    );

    // 2. Get coins earned
    int monedasGanadas = CurrencyManager.calcularRecompensa(
      difficultyString, // Use difficultyString
      puntuacionFinal,
    );
    // 3. Add coins to the user
    await CurrencyManager.addMonedas(monedasGanadas, widget.usuario);

    // 4. Verify achievements
    await AchievementManager.verificarLogros(
      widget.usuario,        // The first argument is the user
      gameNameIdentifier,    // The second argument is the gameNameIdentifier
      difficultyString,      // The third argument is the difficulty
      puntuacionFinal,       // The fourth argument is the score
    );

    // Update best scores for the dialog UI
    await _cargarMejoresPuntuaciones();

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
              Text('You completed the ${_difficulty.name} puzzle'), // Translated
              Text('Moves: $movimientos'), // Translated
              Text('Score: $puntuacionFinal'), // Translated
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('Coins earned: $monedasGanadas'), // Translated
                ],
              ),
              const SizedBox(height: 16), // Add space for best scores
              const Text('Best Scores:'), // Translated
              ...mejoresPuntuaciones // Display loaded best scores
                  .take(5)
                  .map((p) => Text('$p points')) // Translated
                  .toList(),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Back to menu'), // Translated
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Play again'), // Translated
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _initializeGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  // --- _cargarMejoresPuntuaciones FUNCTION (formerly _mostrarResultadoFinal) MODIFIED AND RENAMED ---
  // Now uses CurrencyManager.obtenerLasCincoMejoresPuntuacionesPorJuego
  Future<void> _cargarMejoresPuntuaciones() async {
    // No need to call SharedPreferences.getInstance() here if CurrencyManager is used
    if (!mounted) return;

    String gameNameIdentifier = 'puzzle'; // Internal game ID
    // We don't need difficulty here if `obtenerLasCincoMejoresPuntuacionesPorJuego` consolidates
    // String difficultyString = _difficulty.name;

    // KEY CHANGE: Function name adjusted to the correct one in CurrencyManager
    List<int> loadedScores = await CurrencyManager.obtenerLasCincoMejoresPuntuacionesPorJuego(
      widget.usuario,
      gameNameIdentifier,
      // Do not pass difficultyString here if the consolidated function does not require it
    );

    setState(() {
      mejoresPuntuaciones = loadedScores;
      mejoresPuntuaciones.sort((b, a) => a.compareTo(b)); // Ensure descending order
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // START OF KEY MODIFICATION:
        // Explicitly add the back button in the 'leading' position.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Ensure Navigator can pop before trying.
            // This prevents errors if it's already the first screen.
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text('Sliding Puzzle'), // Translated
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // This is the menu button that opens the Drawer. We move it here from 'leading'.
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
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Options', // Translated
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ExpansionTile(
              title: const Text('Difficulty'), // Translated
              children: [
                ListTile(
                  title: const Text('Beginners (3x3)'), // Translated
                  selected: _difficulty == PuzzleDifficulty.easy, // Translated: facil to easy
                  onTap: () {
                    setState(() {
                      _difficulty = PuzzleDifficulty.easy; // Translated: facil to easy
                      _initializeGame(); // Call the corrected _initializeGame version
                      Navigator.pop(context);
                    });
                  },
                ),
                ListTile(
                  title: const Text('Advanced (5x5)'), // Translated
                  selected: _difficulty == PuzzleDifficulty.hard, // Translated: dificil to hard
                  onTap: () {
                    setState(() {
                      _difficulty = PuzzleDifficulty.hard; // Translated: dificil to hard
                      _initializeGame(); // Call the corrected _initializeGame version
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              'Arrange the image!', // Translated
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Slide the pieces to complete the image', // Translated
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) {
                  if (tiles[index] == 0) {
                    return Container(color: Colors.grey[300]);
                  }

                  final tileNumber = tiles[index];
                  final row = (tileNumber - 1) ~/ gridSize;
                  final col = (tileNumber - 1) % gridSize;

                  return GestureDetector(
                    onTap: () => _moveTile(index),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          child: Transform.scale(
                            scale: gridSize.toDouble(),
                            alignment: Alignment(
                              -1 + 2 * col / (gridSize - 1),
                              -1 + 2 * row / (gridSize - 1),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
                              child: Image(
                                image: puzzleImage.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Ensure the timer is cancelled if used
    super.dispose();
  }
}
