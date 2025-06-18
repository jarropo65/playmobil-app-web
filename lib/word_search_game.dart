// lib/word_search_game.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_manager.dart'; // Import CurrencyManager
import 'achievements.dart'; // Import AchievementsManager
import 'screens/achievements_screen.dart'; // Assuming AchievementsScreen might need the user

enum WordSearchDifficulty { easy, hard } // Translated enum values

class WordSearchGame extends StatefulWidget {
  final String usuario;

  const WordSearchGame({super.key, required this.usuario});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  WordSearchDifficulty _currentDifficulty = WordSearchDifficulty.easy; // Translated: facil to easy
  late int _rows;
  late int _cols;
  late List<String> _words; // This is the list we are going to modify
  late List<List<String>> _grid;
  late List<List<bool>> _selectedCells;
  List<Map<String, int>> _currentSelection = [];
  Set<String> _foundWords = {};
  int _tiempoRestante = 120; // Example: 2 minutes (if no timer, this value is fixed on win)
  bool _juegoTerminado = false;
  // Timer? _timer; // Uncomment if a timer is used
  // List<int> _mejoresPuntuacionesSopa = []; // If you wanted to show best scores on this screen

  @override
  void initState() {
    super.initState();
    _configurarDificultad();
    iniciarJuego();
    // Optional: If you want to load best scores for this screen, do it here.
    // _cargarMejoresPuntuaciones();
  }

  void _configurarDificultad() {
    switch (_currentDifficulty) {
      case WordSearchDifficulty.easy: // Translated: facil
        _rows = 8;
        _cols = 8;
        _words = ['JEANS', 'DRESS', 'SKIRT', 'SHOES']; // These are already English
        _tiempoRestante = 120;
        break;
      case WordSearchDifficulty.hard: // Translated: dificil
        _rows = 14;
        _cols = 14;
        _words = [
          'JUMPER',
          'BLOUSE',
          'JOGGERS',
          'SHIRT',
          'RAINCOAT',
          'SCARF',
          'JACKET',
          'GLOVES'
        ]; // These are already English
        _tiempoRestante = 90;
        break;
    }
  }

  void iniciarJuego() {
    _grid = List.generate(_rows, (_) => List.filled(_cols, ''));
    _selectedCells = List.generate(_rows, (_) => List.filled(_cols, false));
    _currentSelection = [];
    _foundWords = {};
    _juegoTerminado = false;
    // _startTimer(); // Uncomment if a timer is used

    Random random = Random();
    for (String word in _words) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 100) {
        attempts++;
        int row = random.nextInt(_rows);
        int col = random.nextInt(_cols);
        // KEY CHANGE: Limit direction to 0 (Horizontal) or 1 (Vertical)
        int direction = random.nextInt(2); // 0: H, 1: V

        if (direction == 0 && col + word.length <= _cols) { // Horizontal
          bool canPlace = true;
          for (int i = 0; i < word.length; i++) {
            if (_grid[row][col + i] != '' && _grid[row][col + i] != word[i]) {
              canPlace = false;
              break;
            }
          }
          if (canPlace) {
            for (int i = 0; i < word.length; i++) {
              _grid[row][col + i] = word[i];
            }
            placed = true;
          }
        } else if (direction == 1 && row + word.length <= _rows) { // Vertical
          bool canPlace = true;
          for (int i = 0; i < word.length; i++) {
            if (_grid[row + i][col] != '' && _grid[row + i][col] != word[i]) {
              canPlace = false;
              break;
            }
          }
          if (canPlace) {
            for (int i = 0; i < word.length; i++) {
              _grid[row + i][col] = word[i];
            }
            placed = true;
          }
        }
        // Branches for directions 2 and 3 (diagonals) will no longer be reached
        // since 'direction' will only be 0 or 1.
      }
      if (!placed) {
        // debugPrint("Could not place word: $word"); // Translated
      }
    }

    for (int i = 0; i < _rows; i++) {
      for (int j = 0; j < _cols; j++) {
        if (_grid[i][j] == '') {
          _grid[i][j] = String.fromCharCode(random.nextInt(26) + 65);
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleSeleccion(int row, int col) {
    if (_juegoTerminado) return;
    setState(() {
      _selectedCells[row][col] = !_selectedCells[row][col];
      if (_selectedCells[row][col]) {
        _currentSelection.add({'row': row, 'col': col});
      } else {
        _currentSelection.removeWhere(
          (cell) => cell['row'] == row && cell['col'] == col,
        );
      }
    });
  }

  void _verificarSeleccion() {
    if (_currentSelection.isEmpty || _juegoTerminado) return;

    // Logic to determine the selected word (simplified)
    // May need more robust logic to handle non-contiguous selections or different directions.
    // For simplicity, we assume only contiguous cells in a line are selected.
    _currentSelection.sort((a, b) {
      // Sort first by row, then by column for horizontal selections
      if (a['row']! != b['row']!) return a['row']!.compareTo(b['row']!);
      return a['col']!.compareTo(b['col']!);
    });

    String palabraSeleccionada = _currentSelection
        .map((cell) => _grid[cell['row']!][cell['col']!])
        .join('');
    String palabraSeleccionadaInversa = palabraSeleccionada
        .split('')
        .reversed
        .join('');

    bool palabraEncontradaEsteTurno = false;
    for (String word in _words) {
      if (!_foundWords.contains(word) &&
          (palabraSeleccionada == word || palabraSeleccionadaInversa == word)) {
        _foundWords.add(word);
        palabraEncontradaEsteTurno = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Word "$word" found!')) // Translated
        );
        // Deselect cells after finding the word
        for (var cell in _currentSelection) {
          _selectedCells[cell['row']!][cell['col']!] = false;
        }
        _currentSelection.clear();
        break;
      }
    }

    if (!palabraEncontradaEsteTurno && _currentSelection.isNotEmpty) {
      for (var cell in _currentSelection) {
        _selectedCells[cell['row']!][cell['col']!] = false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid word. Try again.')), // Translated
      );
    }
    _currentSelection.clear(); // Clear current selection after checking

    if (_foundWords.length == _words.length) {
      _juegoTerminado = true;
      // _timer?.cancel(); // Uncomment if a timer is used
      _mostrarVictoria();
    }
    setState(() {}); // To refresh UI and selection state
  }

  // --- LOCAL _guardarPuntuacion FUNCTION REMOVED ---
  // Now score and total management is done through CurrencyManager.

  // --- _mostrarVictoria FUNCTION MODIFIED ---
  // Now it's async and uses CurrencyManager to save scores and coins
  Future<void> _mostrarVictoria() async { // Make sure it's 'async'!
    int puntuacion = _tiempoRestante * 10; // Example score calculation
    if (_currentDifficulty == WordSearchDifficulty.hard) { // Translated: dificil
      puntuacion = puntuacion * 2; // Double score for hard
    }
    
    String gameNameIdentifier = "sopa_de_letras"; // Unique identifier
    String difficultyString = _currentDifficulty == WordSearchDifficulty.easy ? "facil" : "dificil"; // Internal keys, kept in Spanish/normalized

    // --- HERE IS THE KEY CHANGE! ---
    // Call CurrencyManager to save score and update totals
    await CurrencyManager.guardarPuntuacion(
      gameNameIdentifier,
      puntuacion,
      widget.usuario, // Pass the user
      difficultyString,
    );

    // Grant coins. IMPORTANT! addMonedas now requires the user.
    await CurrencyManager.addMonedas(20, widget.usuario); 

    // Call verifyAchievements with the correct parameters
    // --- KEY CORRECTION HERE ---
    await AchievementManager.verificarLogros(
      widget.usuario,        // The first argument is the user
      gameNameIdentifier,    // The second argument is the gameNameIdentifier
      difficultyString,      // The third argument is the difficulty
      puntuacion,            // The fourth argument is the score
    );

    if (!mounted) return; // Ensure the widget is still mounted before showing the dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'), // Translated
          content: Text(
            'You found all the words.\nScore: $puntuacion\nCoins earned: 20', // Translated
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'), // Translated
              onPressed: () {
                Navigator.of(context).pop();
                iniciarJuego();
              },
            ),
            TextButton(
              child: const Text('Back to Menu'), // Translated
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous screen (HomePage)
              },
            ),
          ],
        );
      },
    );
  }

  // Optional: If you want a function to load best scores to display on this screen
  /*
  Future<void> _cargarMejoresPuntuaciones() async {
    if (!mounted) return;
    String gameNameIdentifier = "sopa_de_letras";
    String difficultyString = _currentDifficulty == WordSearchDifficulty.easy ? "easy" : "hard";
    
    List<int> loadedScores = await CurrencyManager.obtenerMejoresPuntuacionesPorDificultad(
      widget.usuario,
      gameNameIdentifier,
      difficultyString,
    );
    
    setState(() {
      _mejoresPuntuacionesSopa = loadedScores;
      _mejoresPuntuacionesSopa.sort((b, a) => a.compareTo(b)); // Sort descending
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Word Search'), // Translated
        actions: [
          Builder(
            builder: (BuildContext appBarContext) {
              return IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Difficulty Options', // Translated
                onPressed: () {
                  Scaffold.of(appBarContext).openDrawer();
                },
              );
            }
          ),
          // Button to go to achievements (example, if needed here)
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
          // Show user's coins in the AppBar
          FutureBuilder<int>(
            future: CurrencyManager.getMonedas(widget.usuario), // IMPORTANT! Pass the user
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
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                'Game Options', // Translated
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ExpansionTile(
              title: const Text('Difficulty'), // Translated
              initiallyExpanded: true,
              children: [
                ListTile(
                  title: const Text('Beginners (8x8)'), // Translated
                  selected: _currentDifficulty == WordSearchDifficulty.easy, // Translated: facil to easy
                  onTap: () {
                    if (_currentDifficulty != WordSearchDifficulty.easy) { // Translated: facil to easy
                      setState(() {
                        _currentDifficulty = WordSearchDifficulty.easy; // Translated: facil to easy
                        _configurarDificultad();
                        iniciarJuego();
                      });
                    }
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  title: const Text('Advanced (14x14)'), // Translated
                  selected: _currentDifficulty == WordSearchDifficulty.hard, // Translated: dificil to hard
                  onTap: () {
                    if (_currentDifficulty != WordSearchDifficulty.hard) { // Translated: dificil to hard
                      setState(() {
                        _currentDifficulty = WordSearchDifficulty.hard; // Translated: dificil to hard
                        _configurarDificultad();
                        iniciarJuego();
                      });
                    }
                    Navigator.pop(context); // Close the drawer
                  },
                ),
              ],
            ),
            // You can add more options to the Drawer here if needed
          ],
        ),
      ),
      body: Column(
        children: [
          // Here you could add information like words to find or remaining time
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Words: ${_foundWords.length}/${_words.length}'), // Translated
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: _rows * _cols,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _cols,
                childAspectRatio: 1,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ _cols;
                int col = index % _cols;
                bool isSelected = _selectedCells[row][col];
                String cellText = _grid[row][col];

                return GestureDetector(
                  onTap: () {
                    _toggleSeleccion(row, col);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withAlpha(100) : Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      cellText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : Colors.black54,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _verificarSeleccion,
              child: const Text('Check Selection'), // Translated
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Words to find: ${_words.where((w) => !_foundWords.contains(w)).join(', ')}', // Translated
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // void dispose() {
  //   _timer?.cancel(); // Ensure the timer is cancelled if used
  //   super.dispose();
  // }
}
