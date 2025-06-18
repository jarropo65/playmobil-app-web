// lib/screens/comic_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../currency_manager.dart';
import '../achievements.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class BubbleTarget {
  final Rect position;
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

  final double comicPanelWidth = 70.0;
  final double comicPanelHeight = 100.0;
  final double comicPanelMargin = 4.0;

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
    comicPanelsData = [
      ComicPanelData(
        imagePath: imagesWithoutText[0],
        bubbles: [
          BubbleTarget(position: const Rect.fromLTWH(30, 346, 125, 45), correctText: 'Yes, and he is carrying a leather bag.'),
          BubbleTarget(position: const Rect.fromLTWH(205, 346, 125, 45), correctText: 'Look! That man is wearing a brown jacket!'),
        ],
      ),
      ComicPanelData(
        imagePath: imagesWithoutText[1],
        bubbles: [
          BubbleTarget(position: const Rect.fromLTWH(28, 151, 125, 45), correctText: 'I am wearing a woollen jumper!'),
          BubbleTarget(position: const Rect.fromLTWH(200, 338, 125, 45), correctText: 'You are looking very cool!'),
          BubbleTarget(position: const Rect.fromLTWH(218, 163, 125, 45), correctText: 'I am trying on a red t-shirt.'),
        ],
      ),
      ComicPanelData(
        imagePath: imagesWithoutText[2],
        bubbles: [
          BubbleTarget(position: const Rect.fromLTWH(29, 65, 125, 45), correctText: 'You are smiling! You like them!'),
          BubbleTarget(position: const Rect.fromLTWH(116, 285, 125, 45), correctText: 'I am looking at my new t-shirt.'),
        ],
      ),
      ComicPanelData(
        imagePath: imagesWithoutText[3],
        bubbles: [
          BubbleTarget(position: const Rect.fromLTWH(26, 66, 125, 45), correctText: 'Are you paying with cash or card?'),
          BubbleTarget(position: const Rect.fromLTWH(213, 292, 125, 45), correctText: 'I am paying with my card.'),
          BubbleTarget(position: const Rect.fromLTWH(139, 134, 125, 45), correctText: 'I am holding the bags.'),
        ],
      ),
      ComicPanelData(
        imagePath: imagesWithoutText[4],
        bubbles: [
          BubbleTarget(position: const Rect.fromLTWH(28, 310, 125, 45), correctText: 'Yes, we are walking slowly now!'),
          BubbleTarget(position: const Rect.fromLTWH(208, 310, 125, 45), correctText: 'We are carrying a lot of clothes!'),
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
      puntuacion = 150 - (movimientos > 12 ? (movimientos - 12) * 5 : 0);
      if (puntuacion < 0) puntuacion = 0;
    });

    int monedasGanadas = puntuacion ~/ 10;
    
    // We use _currentDifficulty which was already normalized in _setDifficulty (without accents)
    final String difficultyToSave = _currentDifficulty; 

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
      widget.usuario,        // The first argument is the user
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
        speechBubbles.shuffle();
      }
    });
  }

  Widget _buildDifficultExercise() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Drag and drop the texts into the speech bubbles!', // Translated
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center, // Added alignment for better display
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: comicPanelsData.length,
            itemBuilder: (context, panelIndex) {
              final panel = comicPanelsData[panelIndex];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Image.asset(
                            panel.imagePath,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return Container(
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Text('Error loading image: ${panel.imagePath}', textAlign: TextAlign.center), // Translated
                                ),
                              );
                            },
                          ),
                          ...panel.bubbles.asMap().entries.map((entry) {
                            final bubbleIndex = entry.key;
                            final bubble = entry.value;

                            return Positioned(
                              left: bubble.position.left,
                              top: bubble.position.top,
                              width: bubble.position.width,
                              height: bubble.position.height,
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
                                      child: Text(
                                        bubble.currentText ?? 'Drag here', // Translated
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: bubble.currentText != null ? Colors.black87 : Colors.red[800],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
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
        Container(
          height: 90,
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
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: Center(
                        child: Text(
                          text,
                          style: TextStyle(color: Colors.grey[500], fontSize: 14, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
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
                        child: Text(
                          text,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    childWhenDragging: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
                      ),
                      child: Center(
                        child: Text(
                          text,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
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
  }

  Widget _buildOrderScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Now order the comic panels! - Moves: $movimientos', // Translated
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center, // Added alignment for better display
          ),
        ),
        SizedBox(
          height: comicPanelHeight + (comicPanelMargin * 2) + 10,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: comicPanelWidth,
                    height: comicPanelHeight,
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
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Center(child: Text('Drop here')), // Translated
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
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shuffledImages.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              final imagePath = shuffledImages[index];
              if (slots.contains(imagePath)) {
                return SizedBox(width: comicPanelWidth + (comicPanelMargin * 2));
              }
              return Draggable<String>(
                data: imagePath,
                feedback: Material(
                  elevation: 4.0,
                  color: Colors.transparent,
                  child: Container(
                    width: comicPanelWidth,
                    height: comicPanelHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                childWhenDragging: SizedBox(
                  width: comicPanelWidth,
                  height: comicPanelHeight,
                ),
                dragAnchorStrategy: (draggable, context, position) {
                  return Offset(comicPanelWidth / 2, comicPanelHeight / 2);
                },
                child: Container(
                  width: comicPanelWidth,
                  height: comicPanelHeight,
                  margin: EdgeInsets.all(comicPanelMargin),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
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
}
