// lib/word_game.dart
import 'package:flutter/material.dart';
import 'dart:math'; // Keeping this direct import as previously resolved
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_manager.dart';
import 'achievements.dart'; // Ensure AchievementManager is imported
import 'screens/achievements_screen.dart'; // For the achievements button

// Enum for game difficulty
enum GameDifficulty { easy, hard }

class WordGame extends StatefulWidget {
  final String usuario;
  final GameDifficulty?
      initialDifficulty; // Optional parameter for initial difficulty

  const WordGame({
    super.key,
    required this.usuario,
    this.initialDifficulty, // No longer 'required'
  });

  @override
  State<WordGame> createState() => _WordGameState();
}

class _WordGameState extends State<WordGame> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController controller = TextEditingController();
  final List<String> validWords = [
    // --- NUEVAS PALABRAS INCLUIDAS Y COMBINADAS ---
    // (Ordenadas por longitud y alfabéticamente para mayor claridad)

    // 3-letter words
    'ARM', 'BAG', 'BEL', 'BIB', 'BRA', 'CAP', 'CUF', 'FAN', 'FIT', 'FUR', 'GEM', 'HAT', 'HEM', 'KIT', 'LEG', 'PIN', 'RIG', 'STY', 'TIE', 'TOP', 'ZIP',

    // 4-letter words
    'BAGS', 'BELT', 'BOOT', 'CAPE', 'COAT', 'CUFF', 'DENM', 'FLAT', 'GLOV', 'GOLD', 'GOWN', 'HEEL', 'HOOD', 'IRON', 'JEAN', 'KNIT', 'LACE', 'MASK', 'PANT', 'RING', 'ROBE', 'SALE', 'SCAR', 'SHOE', 'SHRT', 'SILK', 'SLIP', 'SOCK', 'SUIT', 'TUTU', 'VEIL', 'VEST', 'WEAR',

    // 5-letter words
    'APRON', 'BLOUS', 'BOOTS', 'BRACE', 'BRAND', 'CLUTCH', 'CROWN', 'CUFFS', 'DRESS', 'EARRG', 'FASHON', 'GLOVE', 'GOGGLE', 'HEELS', 'HOODIE', 'JACKT', 'JEANS', 'JERSEY', 'LABEL', 'LEGGNG', 'MITTN', 'NECKL', 'OUTFIT', 'PANTS', 'PRICE', 'PURSE', 'ROBES', 'SCARF', 'SHIRT', 'SHOES', 'SKIRT', 'SLIPS', 'SNEAK', 'SOCKS', 'STYLE', 'SWEATR', 'TOWEL', 'TUNIC', 'UNIFRM', 'VISOR', 'WATCH', 'WALLET',

    // 6-letter words
    'APPARE', 'BIKINI', 'BLAZER', 'BLOUSE', 'BOXERS', 'BRACES', 'BUTTON', 'CLOSET', 'COLLAR', 'DIAPER', 'FABRIC', 'GLOVES', 'HANGER', 'HELMET', 'JACKET', 'JUMPER', 'KIMONO', 'MITTEN', 'POCKET', 'SANDAL', 'SHORTS', 'SLEEVE', 'SUNHAT', 'TIGHTS', 'TRUNKS', 'TUXEDO',
  ];
  List<int> mejoresPuntuaciones = []; // Best scores

  late List<String> letters;
  List<String> foundWords = [];
  int score = 0;
  String message = '';
  int streak = 0;
  double multiplier = 1.0;
  Timer? _wordTimer;
  int _timeBonus = 0;
  late int _wordsToWin; // Number of words to win based on difficulty
  late GameDifficulty
      _currentDifficulty; // Variable to manage current difficulty

  @override
  void initState() {
    super.initState();
    _currentDifficulty =
        widget.initialDifficulty ?? GameDifficulty.easy; // Initialize with default value if null
    _wordsToWin = (_currentDifficulty == GameDifficulty.easy) ? 2 : 3;
    _generateNewLetters();
  }

  void _generateNewLetters() {
    const String vocales = 'AEIOU'; // Vowels
    const String consonantes = 'BCDFGHJKLMNPQRSTVWXYZ'; // Consonants

    letters = [];
    for (int i = 0; i < 6; i++) {
      letters.add(vocales[Random().nextInt(vocales.length)]);
    }
    for (int i = 0; i < 9; i++) {
      letters.add(consonantes[Random().nextInt(consonantes.length)]);
    }
    letters.shuffle();
  }

  void _startWordTimer() {
    _timeBonus = 50;
    _wordTimer?.cancel();
    _wordTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_timeBonus > 0) {
        setState(() {
          _timeBonus--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  int _calculateWordScore(String word) {
    int baseScore = word.length * 10;

    int lengthBonus = 0;
    if (word.length >= 5)
      lengthBonus = 30;
    else if (word.length >= 4)
      lengthBonus = 15;

    int timeScore = _timeBonus;

    double finalMultiplier = multiplier;

    return ((baseScore + lengthBonus + timeScore) * finalMultiplier).round();
  }

  bool _canFormWord(String word) {
    List<String> availableLetters = List.from(letters);

    for (var letter in word.split('')) {
      int index = availableLetters.indexOf(letter);
      if (index == -1) {
        return false;
      }
      availableLetters.removeAt(index);
    }
    return true;
  }

  void _checkWord() {
    String word = controller.text.trim().toUpperCase();

    if (word.isEmpty) {
      setState(() {
        message = 'Enter a word'; // Translated
        _resetStreak();
      });
      return;
    }

    if (word.length < 3) {
      setState(() {
        message = 'Word must be at least 3 letters long'; // Translated
        controller.clear();
        _resetStreak();
      });
      return;
    }

    if (foundWords.contains(word)) {
      setState(() {
        message = 'You already found this word!'; // Translated
        controller.clear();
        _resetStreak();
      });
      return;
    }

    if (!_canFormWord(word)) {
      setState(() {
        message = 'Cannot form this word with available letters'; // Translated
        controller.clear();
        _resetStreak();
      });
      return;
    }

    if (validWords.contains(word)) {
      int wordScore = _calculateWordScore(word);
      setState(() {
        foundWords.add(word);
        score += wordScore;
        streak++;
        multiplier = 1.0 + (streak * 0.1);
        message =
            'Correct! +$wordScore points (x${multiplier.toStringAsFixed(1)})'; // Translated
        controller.clear();

        if (foundWords.length >= _wordsToWin) {
          _showVictoryDialog();
        }
      });
      _startWordTimer();
    } else {
      setState(() {
        message = 'Invalid word'; // Translated
        controller.clear();
        _resetStreak();
      });
    }
  }

  void _resetStreak() {
    streak = 0;
    multiplier = 1.0;
    _wordTimer?.cancel();
  }

  void _showVictoryDialog() async {
    _wordTimer?.cancel();

    // KEY CHANGE: Use 'facil' or 'dificil' in lowercase
    String difficultyKey = (_currentDifficulty == GameDifficulty.easy) ? 'facil' : 'dificil';

    // Save score using CurrencyManager with all arguments
    await CurrencyManager.guardarPuntuacion(
      'word_game', // Game identifier
      score,
      widget.usuario,
      difficultyKey, // Pass difficulty in the expected format
    );

    // Calculate coins based on score and difficulty
    int monedasGanadas = CurrencyManager.calcularRecompensa(
      difficultyKey, // Use difficulty in the expected format
      score,
    );
    // addMonedas now requires the user
    await CurrencyManager.addMonedas(monedasGanadas, widget.usuario);

    // Verify achievements
    // --- KEY CORRECTION HERE ---
    await AchievementManager.verificarLogros(
      widget.usuario,    // The first argument is the user
      'word_game',       // The second argument is the gameNameIdentifier
      difficultyKey,     // The third argument is the difficulty
      score,             // The fourth argument is the score
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Congratulations!'), // Translated
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You found $_wordsToWin words!'), // Translated
                Text('Score: $score'), // Translated
                const SizedBox(height: 8),
                Text('Max Streak: $streak'), // Translated
                Text('Final Multiplier: x${multiplier.toStringAsFixed(1)}'), // Translated
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Coins earned: $monedasGanadas', // Translated
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Back to menu'), // Translated
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Go back to the previous screen (game list)
                },
              ),
              TextButton(
                child: const Text('Play again'), // Translated
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  setState(() {
                    _generateNewLetters();
                    foundWords.clear();
                    score = 0;
                    message = '';
                    controller.clear();
                    _resetStreak();
                  });
                },
              ),
            ],
          ),
    );
  }

  // Function to change difficulty and restart the game
  void _changeDifficulty(GameDifficulty newDifficulty) {
    if (_currentDifficulty == newDifficulty) return;

    Navigator.of(context).pop(); // Close the Drawer

    setState(() {
      _currentDifficulty = newDifficulty;
      _wordsToWin = (_currentDifficulty == GameDifficulty.easy) ? 2 : 3;
      _generateNewLetters();
      foundWords.clear();
      score = 0;
      message = '';
      controller.clear();
      _resetStreak();
    });
  }

  @override
  Widget build(BuildContext context) {
    String difficultyText =
        (_currentDifficulty == GameDifficulty.easy) ? 'Easy' : 'Hard'; // Translated
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: const BackButton(), // BackButton remains
        title: Text('Word Game - $difficultyText'), // Translated
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              // Pass the user to AchievementsScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AchievementsScreen(usuario: widget.usuario),
                ),
              );
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  FutureBuilder<int>(
                    // getMonedas now requires the user
                    future: CurrencyManager.getMonedas(widget.usuario),
                    builder: (context, snapshot) {
                      return Text(
                        '${snapshot.data ?? 0}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            tooltip: 'Change difficulty', // Translated
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Select Difficulty', // Translated
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.thermostat_auto),
              title: const Text('Beginners'), // Translated
              onTap: () {
                _changeDifficulty(GameDifficulty.easy);
              },
            ),
            ListTile(
              leading: const Icon(Icons.whatshot),
              title: const Text('Advanced'), // Translated
              onTap: () {
                _changeDifficulty(GameDifficulty.hard);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder( // Add LayoutBuilder here
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            const int crossAxisCount = 5;
            const double gridSpacing = 8.0;

            // Calculate the actual available width for the grid cells, accounting for all paddings
            // ListView horizontal padding: 16.0 (left) + 16.0 (right) = 32.0
            // Card horizontal padding: 16.0 (left) + 16.0 (right) = 32.0
            final double availableWidthForGridCells = availableWidth - (16.0 * 2) - (16.0 * 2);

            // Calculate base cellSize based on this available width, and then cap it.
            // This ensures it scales down on small screens but doesn't become enormous on large ones.
            double calculatedCellSize = (availableWidthForGridCells - (crossAxisCount - 1) * gridSpacing) / crossAxisCount;

            // Define a maximum size for individual cells to prevent them from becoming too large.
            const double maxCellDimension = 80.0; // Reduced from 100.0 for smaller appearance

            // Apply min and max constraints to the calculated cell size
            calculatedCellSize = max(50.0, min(maxCellDimension, calculatedCellSize)); // min 50.0, max 80.0

            // Calculate the actual width and height for the grid container based on the capped cell size
            const int numGridRows = 3; // The grid always has 3 rows of letters
            final double gridDisplayWidth = (calculatedCellSize * crossAxisCount) + ((crossAxisCount - 1) * gridSpacing);
            final double gridDisplayHeight = (calculatedCellSize * numGridRows) + ((numGridRows - 1) * gridSpacing);

            // Adjust font size based on the final cell size, with appropriate min/max limits
            final double finalFontSize = max(20.0, min(36.0, calculatedCellSize * 0.45)); // Adjusted values for better aesthetics


            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), // Increased bottom padding
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Score: $score', // Already English
                                    style: const TextStyle(
                                      fontSize: 24, // Keep this fixed or adjust if needed
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Words: ${foundWords.length}/$_wordsToWin', // Already English
                                      style: TextStyle(
                                        color: foundWords.length >= _wordsToWin
                                            ? Colors.green
                                            : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_timeBonus > 0)
                                LinearProgressIndicator(
                                  value: _timeBonus / 50,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange.withOpacity(0.8),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              // Use calculated gridDisplayWidth and gridDisplayHeight
                              Center(
                                child: Container(
                                  width: gridDisplayWidth,
                                  height: gridDisplayHeight,
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: gridSpacing,
                                    crossAxisSpacing: gridSpacing,
                                    childAspectRatio: 1,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: letters
                                        .map(
                                          (letter) => Card(
                                            color: Colors.blue.shade100,
                                            child: Center(
                                              child: Text(
                                                letter,
                                                style: TextStyle(
                                                  fontSize: finalFontSize, // Use dynamically calculated font size
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (foundWords.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Found words:', // Translated
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: foundWords
                                      .map(
                                        (word) => Chip(
                                          label: Text(word),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: message.toLowerCase().contains('correct')
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                        child: ElevatedButton(
                          onPressed: _checkWord,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48), // Make button wider
                          ),
                          child: const Text('Confirm Word'), // Translated
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    hintText: 'Type a word', // Translated
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  keyboardType:
                                      TextInputType.text, // Added for clarity
                                  onSubmitted: (_) => _checkWord(),
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: _checkWord,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _generateNewLetters();
            foundWords.clear();
            score = 0;
            message = '';
            controller.clear();
            _resetStreak();
          });
        },
        tooltip: 'New letters', // Translated
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _wordTimer?.cancel();
    super.dispose();
  }
}
