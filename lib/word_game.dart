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
    // English words related to clothing, complements, and accessories
    // 3-letter words
    'HAT', 'CAP', 'TIE', 'BAG', 'PIN', 'RIG', 'STY', 'CUF', 'HEM', 'BIB',
    'FAN', 'BEL', 'LEG', 'ARM', 'TOP', 'FIT', 'FUR', 'GEM', 'KIT', 'ZIP',

    // 4-letter words
    'SHOE', 'BOOT', 'COAT', 'SUIT', 'VEST', 'SCAR', 'BELT', 'GLOV', 'SOCK',
    'RING',
    'SHRT', // Short for SHIRT if 5 letters is too long for some contexts
    'PANT', 'ROBE', 'CAPE', 'MASK', 'KNIT', 'LACE', 'SILK', 'DENM', // DENIM
    'GOLD', 'SLIP', 'HEEL', 'FLAT', 'HOOD', 'CUFF', 'JEAN', 'BAGS',

    // 5+ letter words
    'SHIRT',
    'PANTS',
    'DRESS',
    'SKIRT',
    'SHOES',
    'SOCKS',
    'GLOVE', // Singular for GLOVES
    'SCARF', 'BLOUS', // BLOUSE
    'JACKT', // JACKET
    'JEANS', 'BOOTS', 'SLIPS', 'ROBES',
    'MITTN', // MITTEN
    'WATCH', 'BRACE', // BRACELET
    'NECKL', // NECKLACE
    'EARRG', // EARRING
    'POCKET', 'BUTTON', 'COLLAR', 'SLEEVE', 'HELMET', 'GOGGLE',
    'SANDAL', 'SNEAK', // SNEAKER
    'SWEATR', // SWEATER
    'TUXEDO', 'UNIFRM', // UNIFORM
    'WALLET', 'PURSE', 'CLUTCH', 'JERSEY', 'HOODIE', 'LEGGNG', // LEGGING
    'OUTFIT', 'APPARE', // APPAREL
    'FASHON', // FASHION
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
            // Number of columns in the letter grid is fixed at 5
            const int crossAxisCount = 5;
            const double gridSpacing = 8.0; // mainAxisSpacing and crossAxisSpacing

            // Calculate ideal cell size, considering padding within the Card and grid spacing
            // The Card has 16.0 padding on all sides. The GridView also has spacing.
            // Total horizontal padding and spacing for the grid:
            // 16.0 (Card left padding) + 16.0 (Card right padding) for the outer Card padding
            // + (crossAxisCount - 1) * gridSpacing for the spacing BETWEEN grid items
            final double totalHorizontalPadding = (16.0 * 2) + ((crossAxisCount - 1) * gridSpacing);
            final double effectiveGridWidth = availableWidth - totalHorizontalPadding;
            
            // Ensure effectiveGridWidth is not negative or zero
            final double cellSize = (effectiveGridWidth > 0) ? effectiveGridWidth / crossAxisCount : 0.0;

            // Adjust font size based on cell size.
            // Ensure font is not too small (e.g., 18) and not too large (e.g., 40)
            final double fontSize = math.max(18.0, math.min(40.0, cellSize * 0.5)); // 0.5 is an arbitrary scaling factor for text size relative to cell size

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
                              // MODIFIED GridView: Use calculated cellSize and fontSize
                              Center( // Center the grid within the card
                                child: Container( // Wrap GridView in a Container to limit its size
                                  width: (cellSize * crossAxisCount) + ((crossAxisCount -1) * gridSpacing), // Explicit width including spacing
                                  // Height will be determined by 3 rows * cellSize + 2 * gridSpacing
                                  height: (3 * cellSize) + (2 * gridSpacing), // 3 rows, 2 spaces between them
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: crossAxisCount, // Fixed at 5
                                    mainAxisSpacing: gridSpacing,
                                    crossAxisSpacing: gridSpacing,
                                    childAspectRatio: 1, // Keep cells square
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: letters
                                        .map(
                                          (letter) => Card(
                                            color: Colors.blue.shade100,
                                            child: Center(
                                              child: Text(
                                                letter,
                                                style: TextStyle(
                                                  fontSize: fontSize, // Use dynamic font size
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
