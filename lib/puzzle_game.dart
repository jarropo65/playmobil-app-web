// lib/puzzle_game.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_manager.dart';
import 'achievements.dart';
import 'screens/achievements_screen.dart'; // Ensure this import is correct
import 'dart:ui' as ui; // Importado para ui.Image


enum PuzzleDifficulty { easy, hard } // Translated enum values

class PuzzleGame extends StatefulWidget {
  final String usuario;
  const PuzzleGame({super.key, required this.usuario});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  PuzzleDifficulty _difficulty = PuzzleDifficulty.easy; // Default: easy
  late List<int> tiles;
  int gridSize = 3; // Initialized, will be set by _initializeGame
  int movimientos = 0;
  bool gameComplete = false;
  ui.Image? _loadedPuzzleImage; // Will hold the actual ui.Image object
  List<int> mejoresPuntuaciones = []; // Best puzzle scores
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeGame(); // Call initializeGame first to set difficulty and gridSize
  }

  @override
  void dispose() {
    _timer?.cancel(); // Ensure the timer is cancelled if used
    // Dispose the loaded image to free up resources
    _loadedPuzzleImage?.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    int imageToLoad = 1; // Default: loads puzzle1.png for easy

    setState(() { // Set state for gridSize and image source before loading image
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

      tiles = List.generate(gridSize * gridSize, (index) {
        final totalTiles = gridSize * gridSize;
        if (index == totalTiles - 1) {
          return 0; // The empty space (0) goes at the end in the solved state
        } else {
          return index + 1; // Numbered pieces from 1 to N-1
        }
      });

      // Shuffle tiles ensuring solvability for odd grid sizes (like 3x3, 5x5)
      _shuffleTilesSolvable();

      movimientos = 0;
      gameComplete = false;
    });

    await _loadImage(imageToLoad); // Call _loadImage with the correct index

    // Load best scores for the current difficulty and user
    await _cargarMejoresPuntuaciones();
  }

  void _shuffleTilesSolvable() {
    final rnd = Random();
    int inversions;
    do {
      tiles.shuffle(rnd);
      inversions = 0;
      for (int i = 0; i < tiles.length - 1; i++) {
        if (tiles[i] == 0) continue; // Skip the empty tile
        for (int j = i + 1; j < tiles.length; j++) {
          if (tiles[j] == 0) continue; // Skip the empty tile
          if (tiles[i] > tiles[j]) {
            inversions++;
          }
        }
      }
    } while (inversions % 2 != 0); // Ensure even number of inversions for odd grid sizes
  }

  Future<void> _loadImage(int imageIndex) async {
    try {
      if (!mounted) return;
      final ImageProvider imageProvider = AssetImage(
        'assets/images/puzzle/puzzle$imageIndex.png',
      );
      // Get ImageStream
      final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
      final Completer<ui.Image> completer = Completer<ui.Image>();
      late ImageStreamListener listener;
      listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
        stream.removeListener(listener); // Remove listener after image is loaded
      });
      stream.addListener(listener);
      final ui.Image image = await completer.future;

      setState(() {
        _loadedPuzzleImage = image;
      });
    } catch (e) {
      debugPrint('Error loading image: $e'); // Translated
      setState(() {
        _loadedPuzzleImage = null; // Clear if error, or set a placeholder image
      });
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
    // Same row, adjacent
    if (index ~/ gridSize == emptyIndex ~/ gridSize) {
      return (index - emptyIndex).abs() == 1;
    }
    // Same column, adjacent
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
    // Check if the last tile is the empty space
    if (tiles.isNotEmpty && tiles.last != 0) {
      win = false;
    }

    if (win) {
      _timer?.cancel();
    }
    return win;
  }

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
      widget.usuario, // The first argument is the user
      gameNameIdentifier, // The second argument is the gameNameIdentifier
      difficultyString, // The third argument is the difficulty
      puntuacionFinal, // The fourth argument is the score
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

  Future<void> _cargarMejoresPuntuaciones() async {
    if (!mounted) return;

    String gameNameIdentifier = 'puzzle'; // Internal game ID
    List<int> loadedScores = await CurrencyManager.obtenerLasCincoMejoresPuntuacionesPorJuego(
      widget.usuario,
      gameNameIdentifier,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text('Sliding Puzzle'), // Translated
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
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
                  selected: _difficulty == PuzzleDifficulty.easy,
                  onTap: () {
                    setState(() {
                      _difficulty = PuzzleDifficulty.easy;
                      _initializeGame();
                      Navigator.pop(context);
                    });
                  },
                ),
                ListTile(
                  title: const Text('Advanced (5x5)'), // Translated
                  selected: _difficulty == PuzzleDifficulty.hard,
                  onTap: () {
                    setState(() {
                      _difficulty = PuzzleDifficulty.hard;
                      _initializeGame();
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
        child: LayoutBuilder( // Add LayoutBuilder for responsiveness
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            double padding = 16.0; // Default padding
            double spacing = 4.0; // Default spacing

            // Adjust padding and spacing for smaller screens
            if (availableWidth < 600) {
              padding = 8.0;
              spacing = 2.0;
            }

            // Calculate max width for the puzzle grid to keep it square and centered
            // Subtract horizontal padding from available width
            final double maxGridDimension = availableWidth - (2 * padding);

            // Determine the size of each tile dynamically
            final double tileSize = (maxGridDimension - (gridSize - 1) * spacing) / gridSize;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: const [
                      Text(
                        'Arrange the image!', // Translated
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Slide the pieces to complete the image', // Translated
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center( // Center the puzzle grid
                    child: _loadedPuzzleImage == null
                        ? const CircularProgressIndicator() // Show loading indicator
                        : Container(
                            width: tileSize * gridSize + (gridSize - 1) * spacing, // Explicitly set grid container width
                            height: tileSize * gridSize + (gridSize - 1) * spacing, // Explicitly set grid container height
                            constraints: BoxConstraints( // Add constraints to limit max size on very large screens
                                maxWidth: 700, // Max width for the puzzle grid
                                maxHeight: 700, // Max height for the puzzle grid
                            ),
                            child: GridView.builder(
                              shrinkWrap: true, // Allow GridView to take only needed space
                              physics: const NeverScrollableScrollPhysics(), // Disable scrolling in the grid
                              padding: EdgeInsets.all(padding),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridSize, // gridSize (3 or 5) is correct for the puzzle grid
                                childAspectRatio: 1, // Keep tiles square
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                              ),
                              itemCount: gridSize * gridSize,
                              itemBuilder: (context, index) {
                                if (tiles[index] == 0) {
                                  return Container(color: Colors.grey[300]);
                                }

                                final tileNumber = tiles[index];
                                // Calculate row and col of the ORIGINAL piece in the full image
                                final originalRow = (tileNumber - 1) ~/ gridSize;
                                final originalCol = (tileNumber - 1) % gridSize;

                                return GestureDetector(
                                  onTap: () => _moveTile(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CustomPaint( // Use CustomPaint for precise image slicing
                                        painter: _PuzzlePiecePainter(
                                          image: _loadedPuzzleImage!, // Pass the loaded ui.Image
                                          tileNumber: tileNumber,
                                          gridSize: gridSize,
                                          originalRow: originalRow,
                                          originalCol: originalCol,
                                        ),
                                        child: Container(), // CustomPaint handles drawing, child is optional
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
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

// Custom Painter for drawing individual puzzle pieces
class _PuzzlePiecePainter extends CustomPainter {
  final ui.Image image; // Now directly pass ui.Image
  final int tileNumber;
  final int gridSize;
  final int originalRow;
  final int originalCol;
  
  _PuzzlePiecePainter({
    required this.image,
    required this.tileNumber,
    required this.gridSize,
    required this.originalRow,
    required this.originalCol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (tileNumber == 0) return; // Don't draw the empty tile

    final imgWidth = image.width.toDouble();
    final imgHeight = image.height.toDouble();

    final pieceSrcWidth = imgWidth / gridSize;
    final pieceSrcHeight = imgHeight / gridSize;

    // Source rect in the original image (pixel coordinates)
    final srcRect = Rect.fromLTWH(
      originalCol * pieceSrcWidth,
      originalRow * pieceSrcHeight,
      pieceSrcWidth,
      pieceSrcHeight,
    );

    // Destination rect on the canvas (local coordinates of the tile)
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(image, srcRect, dstRect, Paint());
  }

  @override
  bool shouldRepaint(covariant _PuzzlePiecePainter oldDelegate) {
    // Repaint only if image, tileNumber, gridSize, or originalRow/Col changes
    return oldDelegate.image != image ||
           oldDelegate.tileNumber != tileNumber ||
           oldDelegate.gridSize != gridSize ||
           oldDelegate.originalRow != originalRow ||
           oldDelegate.originalCol != originalCol;
  }
}
