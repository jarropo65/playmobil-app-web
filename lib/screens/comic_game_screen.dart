// lib/screens/comic_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../currency_manager.dart';
import '../achievements.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'dart:math' as math; // Explicit import for min/max functions
import 'package:auto_size_text/auto_size_text.dart'; // Import for AutoSizeText

class BubbleTarget {
  final Rect position; // Position in original image coordinates
  final String correctText;
  String? currentText;

  BubbleTarget({
    required this.position,
    required this.correctText,
    this.currentText,
  });

  BubbleTarget copyWith({String? currentText}) {
    return BubbleTarget(
      position: position,
      correctText: correctText,
      currentText: currentText ?? this.currentText,
    );
  }
}

class ComicPanelData {
  final String imagePath;
  final List<BubbleTarget> bubbles;

  ComicPanelData({required this.imagePath, required this.bubbles});
}

class ComicGameScreen extends StatefulWidget {
  final String usuario;
  const ComicGameScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  _ComicGameScreenState createState() => _ComicGameScreenState();
}

class _ComicGameScreenState extends State<ComicGameScreen> {
  static const String _gameNameIdentifier = 'comic_game';

  // Assuming original image resolution for bubble positions (e.g., image1_sin_texto.png)
  // These dimensions are critical for scaling the bubble positions correctly.
  // Based on the provided images, a common aspect ratio for the panels seems to be around 360x480.
  static const Size _originalComicPanelImageSize = Size(360, 480); // Width x Height

  List<String> imagesWithBubbles = [
    'assets/images/comic_game/image1.png',
    'assets/images/comic_game/image2.png',
    'assets/images/comic_game/image3.png',
    'assets/images/comic_game/image4.png',
    'assets/images/comic_game/image5.png',
  ];

  List<String> imagesWithoutBubbles = [
    'assets/images/comic_game/image1_sin_bocadillo.png',
    'assets/images/comic_game/image2_sin_bocadillo.png',
    'assets/images/comic_game/image3_sin_bocadillo.png',
    'assets/images/comic_game/image4_sin_bocadillo.png',
    'assets/images/comic_game/image5_sin_bocadillo.png',
  ];

  List<String> imagesWithoutText = [
    'assets/images/comic_game/image1_sin_texto.png',
    'assets/images/comic_game/image2_sin_texto.png',
    'assets/images/comic_game/image3_sin_texto.png',
    'assets/images/comic_game/image4_sin_texto.png',
    'assets/images/comic_game/image5_sin_texto.png',
  ];

  List<String> speechBubbles = [
    'Look! That man is wearing a brown jacket!', 'Yes, and he is carrying a leather bag.', 'I am trying on a red t-shirt.', 'I am wearing a woollen jumper!',
    'You are looking very cool!', 'I am looking at my new t-shirt.', 'You are smiling! You like them!', 'Are you paying with cash or card?',
    'I am paying with my card.', 'I am holding the bags.', 'We are carrying a lot of clothes!', 'Yes, we are walking slowly now!',
  ];

  late List<BubbleTarget> _allBubblesForDifficultExercise;
  late List<ComicPanelData> comicPanelsData;

  int currentImageIndex = 0;
  bool showImages = true;
  bool showOrderScreen = false;
  bool showDifficultExercise = false;

  List<String> shuffledImages = [];
  List<String?> slots = List.filled(5, null);
  int movimientos = 0; // Moves
  int puntuacion = 0; // Score
  bool juegoTerminado = false; // Game finished

  // IMPORTANT! This variable will store the difficulty WITHOUT ACCENTS for saving.
  String _currentDifficulty = 'initial'; // Initial difficulty state

  final double comicPanelMargin = 4.0; // Margin can remain fixed

  final ScrollController _textScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeComicPanelsData();
    startInitialImageDisplay();
  }

  @override
  void dispose() {
    _textScrollController.dispose();
    super.dispose();
  }

  void _initializeComicPanelsData() {
    // Adjusted Rect heights for better text wrapping.
    // The width/height values are based on the _originalComicPanelImageSize (360x480).
    // The left/top positions are relative to that original size.
    // Increased height from 45 to 60 for better multi-line text display.
    comicPanelsData = [
      ComicPanelData(
        imagePath: imagesWithoutText[0],
        bubbles: [
          BubbleTarget(position: const Rect.fromLTWH(45, 255, 125, 60), correctText: 'Yes, and he is carrying a leather bag.'),
          BubbleTarget(position: const Rect.fromLTWH(195, 255, 125, 60), correctText: 'Look! That man is wearing a brown jacket!'),
        ],
      ),
      ComicPanelData(
        imagePath: imagesWithoutText[1],
        bubbles: [
          BubbleTarget(position: const Rect.fromLTWH(40, 100, 125, 60), correctText: 'I am wearing a woollen jumper!'),
          BubbleTarget(position: const Rect.fromLTWH(185, 250, 125, 60), correctText: 'You are looking very cool!'),
          BubbleTarget(position: const Rect.fromLTWH(190, 120, 125, 60), correctText: 'I am trying on a red t-shirt.'),
        ],
      ),
      ComicPanelData(
        imagePath: imagesWithoutText[2],
        bubbles: [
          BubbleTarget(position: const Rect.fromLTWH(50, 35, 125, 60), correctText: 'You are smiling! You like them!'),
          BubbleTarget(position: const Rect.fromLTWH(112, 205, 125, 60), correctText: 'I am looking at my new t-shirt.'),
        ],
      ),
      ComicPanelData(
        imagePath: imagesWithoutText[3],
        bubbles: [
          BubbleTarget(position: const Rect.fromLTWH(45, 28, 125, 60), correctText: 'Are you paying with cash or card?'),
          BubbleTarget(position: const Rect.fromLTWH(180, 215, 125, 60), correctText: 'I am paying with my card.'),
          BubbleTarget(position: const Rect.fromLTWH(132, 90, 125, 60), correctText: 'I am holding the bags.'),
        ],
      ),
      ComicPanelData(
        imagePath: imagesWithoutText[4],
        bubbles: [
          BubbleTarget(position: const Rect.fromLTWH(35, 225, 125, 60), correctText: 'Yes, we are walking slowly now!'),
          BubbleTarget(position: const Rect.fromLTWH(190, 225, 125, 60), correctText: 'We are carrying a lot of clothes!'),
        ],
      ),
    ];
    _allBubblesForDifficultExercise = comicPanelsData.expand((panel) => panel.bubbles).toList();
  }

  void startInitialImageDisplay() {
    currentImageIndex = 0;
    showImages = true;
    showOrderScreen = false;
    showDifficultExercise = false;
    movimientos = 0;
    puntuacion = 0;
    juegoTerminado = false;
    slots = List.filled(5, null);

    Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (currentImageIndex < imagesWithBubbles.length - 1) {
        if (mounted) {
          setState(() {
            currentImageIndex++;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            showImages = false;
            _goToDifficultySelection();
          });
        }
      }
    });
  }

  void _goToDifficultySelection() {
    setState(() {
      showImages = false;
      showOrderScreen = false;
      showDifficultExercise = false;
      movimientos = 0;
      puntuacion = 0;
      juegoTerminado = false;
      slots = List.filled(5, null);
      _initializeComicPanelsData();
      speechBubbles.shuffle();
      _currentDifficulty = 'initial'; // Reset difficulty to unselected state
    });
  }

  void reiniciarJuego() async { // Restart Game
    setState(() {
      puntuacion = 0;
      juegoTerminado = false;
      movimientos = 0;
      _initializeComicPanelsData();
      if (showOrderScreen) {
        slots = List.filled(5, null);
        shuffledImages = List.from(imagesWithoutBubbles.take(5))..shuffle();
      } else if (showDifficultExercise) {
        // Reset currentText for all bubbles when restarting difficult game
        for (var panel in comicPanelsData) {
          for (var bubble in panel.bubbles) {
            bubble.currentText = null;
          }
        }
        speechBubbles.shuffle();
      }
    });
  }

  void verificarOrden() { // Verify Order
    if (juegoTerminado) return;

    bool correcto = true;
    for (int i = 0; i < slots.length; i++) {
      if (slots[i] != imagesWithoutBubbles[i]) {
        correcto = false;
        break;
      }
    }

    if (correcto) {
      _mostrarDialogoVictoria();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Some images are not in the correct order. Keep trying!')), // Translated
      );
    }
  }

  void verificarTextos() { // Verify Texts
    if (juegoTerminado) return;

    bool correcto = true;
    for (var panel in comicPanelsData) {
      for (var bubble in panel.bubbles) {
        if (bubble.currentText == null || bubble.currentText != bubble.correctText) {
          correcto = false;
          break;
        }
      }
      if (!correcto) break;
    }

    if (correcto) {
      _mostrarDialogoVictoria();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Some texts are incorrect or missing. Keep trying!')), // Translated
      );
    }
  }

  Future<void> _mostrarDialogoVictoria() async { // Show Victory Dialog
    setState(() {
      juegoTerminado = true;
      // Calculate score based on difficulty and moves
      int baseScore = _currentDifficulty == 'facil' ? 100 : 150;
      int penaltyPerMove = _currentDifficulty == 'facil' ? 5 : 10;
      int maxMovesForFullScore = _currentDifficulty == 'facil' ? 10 : 12;

      puntuacion = baseScore - (movimientos > maxMovesForFullScore ? (movimientos - maxMovesForFullScore) * penaltyPerMove : 0);
      if (puntuacion < 0) puntuacion = 0; // Ensure score doesn't go below 0
    });

    int monedasGanadas = CurrencyManager.calcularRecompensa(_currentDifficulty, puntuacion);
    
    final String difficultyToSave = _currentDifficulty; // Already normalized

    debugPrint('*** ComicGameScreen: STARTING CALL TO SAVE SCORE ***'); // Translated
    debugPrint('  gameNameIdentifier: "$_gameNameIdentifier"');
    debugPrint('  score: $puntuacion'); // Translated
    debugPrint('  user: "${widget.usuario}"'); // Translated
    debugPrint('  difficultyToSave (FINAL): "$difficultyToSave"'); // Should be 'facil' or 'dificil' (without accent) // Translated
    debugPrint('*** END CALL TO SAVE SCORE ***'); // Translated

    await CurrencyManager.guardarPuntuacion(
      _gameNameIdentifier,
      puntuacion,
      widget.usuario,
      difficultyToSave,
    );

    await CurrencyManager.addMonedas(monedasGanadas, widget.usuario);

    // --- KEY CORRECTION HERE ---
    await AchievementManager.verificarLogros(
      widget.usuario,    // The first argument is the user
      _gameNameIdentifier, // The second argument is the gameNameIdentifier
      difficultyToSave,    // The third argument is the difficulty
      puntuacion,          // The fourth argument is the score
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('You Won the Challenge!'), // Translated
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Moves: $movimientos'), // Translated
              Text('Score: $puntuacion'), // Translated
              Text('Coins Earned: $monedasGanadas'), // Translated
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Restart'), // Translated
              onPressed: () {
                Navigator.of(context).pop();
                reiniciarJuego();
              },
            ),
            TextButton(
              child: const Text('Back to Menu'), // Translated
              onPressed: () {
                Navigator.of(context).pop();
                _goToDifficultySelection();
              },
            ),
          ],
        );
      },
    );
  }

  // Helper to normalize difficulty strings without accent
  String _normalizeDifficultyString(String input) {
    String lower = input.toLowerCase();
    if (lower == 'fácil') return 'facil'; // Keep 'facil' as internal ID
    if (lower == 'difícil') return 'dificil'; // Keep 'dificil' as internal ID
    return lower; // Return as is if it doesn't have accent or is not 'fácil'/'difícil'
  }

  void _setDifficulty(String newDifficultyDisplay) {
    setState(() {
      // Normalize difficulty here so it's always without accents
      _currentDifficulty = _normalizeDifficultyString(newDifficultyDisplay);  
      debugPrint('ComicGameScreen: Selected AND NORMALIZED difficulty: "$_currentDifficulty"'); // Translated
      showImages = false;
      // Comparisons here should also be with the normalized string
      showOrderScreen = _currentDifficulty == 'facil'; // Without accent
      showDifficultExercise = _currentDifficulty == 'dificil'; // Without accent
      movimientos = 0;
      puntuacion = 0;
      juegoTerminado = false;

      _initializeComicPanelsData();
      if (showOrderScreen) {
        slots = List.filled(5, null);
        shuffledImages = List.from(imagesWithoutBubbles.take(5))..shuffle();
      } else if (showDifficultExercise) {
        // Reset currentText for all bubbles when starting difficult game
        for (var panel in comicPanelsData) {
          for (var bubble in panel.bubbles) {
            bubble.currentText = null;
          }
        }
        speechBubbles.shuffle();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comic Game'), // Translated
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
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
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Options', // Translated
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Beginners'), // Translated: Fácil to Easy
              onTap: () {
                _setDifficulty('Fácil'); // Still pass 'Fácil' for normalization
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Advanced'), // Translated: Difícil to Hard
              onTap: () {
                _setDifficulty('Difícil'); // Still pass 'Difícil' for normalization
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: showImages
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(imagesWithBubbles[currentImageIndex]),
                ),
              )
            : showOrderScreen
                ? _buildOrderScreen()
                : showDifficultExercise
                    ? _buildDifficultExercise()
                    : Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/playmobil_comic_fondo.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20.0),
                                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/characters/happy_kid.png',
                                      height: 100,
                                      width: 100,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.sentiment_very_satisfied, size: 80, color: Colors.blueAccent),
                                    ),
                                    const SizedBox(height: 15),
                                    const Text(
                                      'Welcome to the Comic Game!', // Translated
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Choose a difficulty from the side menu', // Translated
                                      style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  // --- MODIFIED _buildDifficultExercise FUNCTION FOR RESPONSIVENESS AND TEXT SIZE ---
  Widget _buildDifficultExercise() {
    return LayoutBuilder( // Use LayoutBuilder to get available space
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        // The image height should scale proportionally to its width
        // We calculate maxImageWidth to ensure it doesn't get too big on very wide screens
        final double maxImageWidth = math.min(availableWidth * 0.95, 600.0); // Limit max width
        final double panelImageHeight = maxImageWidth * (_originalComicPanelImageSize.height / _originalComicPanelImageSize.width);

        // Adjust padding and margins for responsiveness
        double panelHorizontalPadding = availableWidth * 0.02; // 2% of screen width
        panelHorizontalPadding = math.max(8.0, math.min(panelHorizontalPadding, 24.0)); // Min 8, Max 24

        // Draggable text cards:
        // We need to estimate how many can fit, but also allow them to wrap text
        // Set a preferred width for the draggable text cards, let height be determined by AutoSizeText
        double draggableCardWidth = (availableWidth - (2 * panelHorizontalPadding) - (5 * 12)) / 5; // Attempt to fit 5, with spacing
        draggableCardWidth = math.max(120.0, math.min(draggableCardWidth, 180.0)); // Keep draggable cards between 120 and 180 width

        // Font size for draggable/droppable texts. Let AutoSizeText handle min/max.
        double baseTextFontSize = availableWidth < 600 ? 14.0 : 16.0; // Base size for small/large screens


        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Drag and drop the texts into the speech bubbles!', // Translated
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: comicPanelsData.length,
                itemBuilder: (context, panelIndex) {
                  final panel = comicPanelsData[panelIndex];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: panelHorizontalPadding),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // Stack for image and bubbles
                          Stack(
                            alignment: Alignment.center, // Center the image within the stack
                            children: [
                              // Comic panel image
                              Image.asset(
                                panel.imagePath,
                                // Dynamically adjust width based on available space, maintaining aspect ratio
                                width: maxImageWidth,
                                height: panelImageHeight,
                                fit: BoxFit.contain, // Changed to contain to ensure full image is visible
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  return Container(
                                    width: maxImageWidth,
                                    height: panelImageHeight,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Text('Error loading image: ${panel.imagePath}', textAlign: TextAlign.center), // Translated
                                    ),
                                  );
                                },
                              ),
                              // Speech bubbles (positioned dynamically)
                              ...panel.bubbles.asMap().entries.map((entry) {
                                final bubbleIndex = entry.key;
                                final bubble = entry.value;

                                // Calculate scaled position based on the actual rendered image size
                                final double scaleX = maxImageWidth / _originalComicPanelImageSize.width;
                                final double scaleY = panelImageHeight / _originalComicPanelImageSize.height;

                                return Positioned(
                                  left: bubble.position.left * scaleX,
                                  top: bubble.position.top * scaleY,
                                  width: bubble.position.width * scaleX,
                                  height: bubble.position.height * scaleY, // Use scaled height
                                  child: DragTarget<String>(
                                    builder: (context, candidateData, rejectedData) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: candidateData.isNotEmpty ? Colors.green : Colors.red,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                          color: bubble.currentText != null ? Colors.blue[100]!.withOpacity(0.7) : Colors.grey[200]!.withOpacity(0.7),
                                        ),
                                        child: Center(
                                          child: AutoSizeText( // Use AutoSizeText here
                                            bubble.currentText ?? 'Drag here', // Translated
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: bubble.currentText != null ? Colors.black87 : Colors.red[800],
                                              fontSize: baseTextFontSize, // Use base font size, AutoSizeText will adapt
                                              fontWeight: FontWeight.bold,
                                            ),
                                            minFontSize: 10, // Minimum font size
                                            maxLines: 2, // Allow two lines of text
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                    },
                                    onWillAccept: (data) {
                                      bool isTextUsed = _allBubblesForDifficultExercise.any((b) => b != bubble && b.currentText == data);
                                      return bubble.currentText == null && !isTextUsed;
                                    },
                                    onAccept: (data) {
                                      setState(() {
                                        for (var otherBubble in _allBubblesForDifficultExercise) {
                                          if (otherBubble != bubble && otherBubble.currentText == data) {
                                            otherBubble.currentText = null;
                                            break;
                                          }
                                        }
                                        bubble.currentText = data;
                                        movimientos++;
                                        HapticFeedback.mediumImpact();
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Draggable text bubbles container
            Container(
              height: 100, // Increased height to comfortably fit two lines of text
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.blueGrey[50],
              child: ClipRect(
                child: Scrollbar(
                  controller: _textScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 8.0,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    controller: _textScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: speechBubbles.length,
                    itemBuilder: (context, textIndex) {
                      final text = speechBubbles[textIndex];
                      bool isTextUsed = _allBubblesForDifficultExercise.any((bubble) => bubble.currentText == text);

                      if (isTextUsed) {
                        return Container(
                          width: draggableCardWidth, // Dynamic width for text bubbles
                          margin: const EdgeInsets.symmetric(horizontal: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: Center(
                            child: AutoSizeText( // Use AutoSizeText here
                              text,
                              style: TextStyle(color: Colors.grey[500], fontSize: baseTextFontSize, fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                              minFontSize: 10, // Minimum font size
                              maxLines: 2, // Allow two lines of text
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      } else {
                        return LongPressDraggable<String>(
                          data: text,
                          feedback: Material(
                            elevation: 4.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: AutoSizeText( // Use AutoSizeText here
                                text,
                                style: TextStyle(color: Colors.white, fontSize: baseTextFontSize, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                minFontSize: 10,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          childWhenDragging: Container(
                            width: draggableCardWidth, // Dynamic width for text bubbles
                            margin: const EdgeInsets.symmetric(horizontal: 6.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: AutoSizeText( // Use AutoSizeText here
                              text,
                              style: TextStyle(color: Colors.grey[500], fontSize: baseTextFontSize),
                              textAlign: TextAlign.center,
                              minFontSize: 10,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          dragAnchorStrategy: (draggable, context, position) {
                            return Offset(draggableCardWidth / 2, 50); // Dynamic anchor based on card width
                          },
                          child: Container(
                            width: draggableCardWidth, // Dynamic width for text bubbles
                            margin: const EdgeInsets.symmetric(horizontal: 6.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
                            ),
                            child: Center(
                              child: AutoSizeText( // Use AutoSizeText here
                                text,
                                style: TextStyle(color: Colors.white, fontSize: baseTextFontSize, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                minFontSize: 10,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: verificarTextos,
                      child: const Text('Verify Texts'), // Translated
                    ),
                    ElevatedButton(
                      onPressed: reiniciarJuego,
                      child: const Text('Restart'), // Translated
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- MODIFIED _buildOrderScreen FUNCTION FOR RESPONSIVENESS ---
  Widget _buildOrderScreen() {
    return LayoutBuilder( // Use LayoutBuilder to get available space
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        // We have 5 panels. We want them to fit horizontally if possible.
        // Let's reserve some padding and spacing.
        final int numberOfPanels = 5;
        double panelSpacing = 8.0; // Spacing between panels
        double totalHorizontalPadding = 16.0; // Total padding on left/right of the list
        
        // Calculate dynamic panel width
        double dynamicPanelWidth = (availableWidth - totalHorizontalPadding - (panelSpacing * (numberOfPanels - 1))) / numberOfPanels;
        
        // Set a max width for panels to prevent them from becoming too large on very wide screens
        dynamicPanelWidth = math.min(dynamicPanelWidth, 120.0); // Max width for a single panel

        double dynamicPanelHeight = dynamicPanelWidth * (_originalComicPanelImageSize.height / _originalComicPanelImageSize.width);
        dynamicPanelHeight = math.min(dynamicPanelHeight, 160.0); // Max height for a single panel


        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Now order the comic panels! - Moves: $movimientos', // Translated
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            // Draggable slots for placing images
            SizedBox(
              // Calculate height dynamically based on content + margins
              height: dynamicPanelHeight + (comicPanelMargin * 2) + 20, // Add extra for text 'Drop here'
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: numberOfPanels, // Always 5 slots
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: dynamicPanelWidth, // Dynamic width
                        height: dynamicPanelHeight, // Dynamic height
                        margin: EdgeInsets.all(comicPanelMargin),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: slots[index] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(3.0),
                                child: Image.asset(
                                  slots[index]!,
                                  fit: BoxFit.contain, // Changed to contain
                                ),
                              )
                            : const Center(child: Text('Drop here', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))), // Translated, smaller font
                      );
                    },
                    onWillAccept: (data) {
                      return slots[index] == null && !slots.contains(data);
                    },
                    onAccept: (data) {
                      setState(() {
                        final previousIndex = slots.indexOf(data);
                        if (previousIndex != -1) {
                          slots[previousIndex] = null;
                        }
                        slots[index] = data;
                        movimientos++;
                        HapticFeedback.mediumImpact();
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Draggable images to be ordered
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: shuffledImages.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  final imagePath = shuffledImages[index];
                  if (slots.contains(imagePath)) {
                    // Make sure the placeholder for used images has correct dynamic size
                    return SizedBox(width: dynamicPanelWidth + (comicPanelMargin * 2));
                  }
                  return Draggable<String>(
                    data: imagePath,
                    feedback: Material(
                      elevation: 4.0,
                      color: Colors.transparent,
                      child: Container(
                        width: dynamicPanelWidth, // Dynamic width
                        height: dynamicPanelHeight, // Dynamic height
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain, // Changed to contain
                          ),
                        ),
                      ),
                    ),
                    childWhenDragging: SizedBox(
                      width: dynamicPanelWidth, // Dynamic width
                      height: dynamicPanelHeight, // Dynamic height
                    ),
                    dragAnchorStrategy: (draggable, context, position) {
                      return Offset(dynamicPanelWidth / 2, dynamicPanelHeight / 2); // Dynamic anchor
                    },
                    child: Container(
                      width: dynamicPanelWidth, // Dynamic width
                      height: dynamicPanelHeight, // Dynamic height
                      margin: EdgeInsets.all(comicPanelMargin),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain, // Changed to contain
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: verificarOrden,
                    child: const Text('Verify'), // Translated
                  ),
                  ElevatedButton(
                    onPressed: reiniciarJuego,
                    child: const Text('Restart'), // Translated
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
