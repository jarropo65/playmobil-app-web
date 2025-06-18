// lib/currency_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'dart:async'; // Import for StreamController

class CurrencyManager {
  static const String _monedasKeyPrefix = 'monedas_';
  static const String _totalPuntuacionAcumuladaKeyPrefix = 'total_puntuacion_acumulada_';
  static const String _juegosCompletadosKeyPrefix = 'juegos_completados_';
  static const String _topScoresKeyPrefix = 'top_scores_';

  // These are internal keys, so they remain as they are for logic, but we include both Spanish and English normalized versions.
  static const List<String> knownDifficulties = ['facil', 'dificil', 'normal', 'easy', 'hard', 'fácil', 'difícil'];

  // --- MODIFIED: Use a single static StreamController for all coin updates ---
  // A single StreamController that broadcasts updates to all listeners.
  // We make it late and private, and provide a static getter for its stream.
  static late StreamController<Map<String, int>> _monedasStreamController;
  static bool _isInitialized = false;

  // Initialize the StreamController if it hasn't been already
  static void initialize() {
    if (!_isInitialized) {
      _monedasStreamController = StreamController<Map<String, int>>.broadcast();
      _isInitialized = true;
      debugPrint('CurrencyManager: StreamController initialized.');
    }
  }

  // Get the stream of all user coins.
  // The stream will emit a Map<String, int> where key is userId and value is coins.
  static Stream<Map<String, int>> get allMonedasStream {
    initialize(); // Ensure the controller is initialized
    return _monedasStreamController.stream;
  }

  // Helper method to notify all listeners (through the stream) about coin changes for a specific user
  static Future<void> _notificarCambioMonedas(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final int currentMonedas = prefs.getInt('$_monedasKeyPrefix$usuario') ?? 0;
    if (_monedasStreamController.isClosed) {
      debugPrint('CurrencyManager: Attempted to add to a closed stream for $usuario. Reinitializing...');
      initialize(); // Reinitialize if somehow closed (shouldn't happen in normal app lifecycle)
    }
    // Emit a map containing only the updated user's coins for efficiency
    _monedasStreamController.add({usuario: currentMonedas});
    debugPrint('CurrencyManager: Notified new coin total for $usuario: $currentMonedas');
  }

  // --- MODIFIED: getMonedas now also triggers a stream update on load ---
  static Future<int> getMonedas(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final int currentMonedas = prefs.getInt('$_monedasKeyPrefix$usuario') ?? 0;
    // Notify the stream with the current value whenever it's requested
    await _notificarCambioMonedas(usuario);
    return currentMonedas;
  }

  // --- MODIFIED: addMonedas now notifies listeners ---
  static Future<void> addMonedas(int cantidad, String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    int currentMonedas = prefs.getInt('$_monedasKeyPrefix$usuario') ?? 0;
    int newTotal = currentMonedas + cantidad;
    await prefs.setInt('$_monedasKeyPrefix$usuario', newTotal);
    debugPrint('CurrencyManager: Added $cantidad coins to $usuario. Total: $newTotal');
    await _notificarCambioMonedas(usuario); // Notify listeners
  }

  // --- MODIFIED: gastarMonedas now notifies listeners ---
  static Future<bool> gastarMonedas(int cantidad, String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    int currentMonedas = prefs.getInt('$_monedasKeyPrefix$usuario') ?? 0;

    if (currentMonedas >= cantidad) {
      int newTotal = currentMonedas - cantidad;
      await prefs.setInt('$_monedasKeyPrefix$usuario', newTotal);
      debugPrint('CurrencyManager: Spent $cantidad coins from $usuario. Remaining: $newTotal');
      await _notificarCambioMonedas(usuario); // Notify listeners
      return true;
    } else {
      debugPrint('CurrencyManager: Insufficient funds for $usuario. Tried to spend $cantidad, has $currentMonedas.');
      return false;
    }
  }

  static int calcularRecompensa(String dificultad, int puntuacion) {
    int monedasBase = 0;
    String normalizedDifficulty = dificultad.toLowerCase();
    normalizedDifficulty = normalizedDifficulty.replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');

    switch (normalizedDifficulty) {
      case 'facil':
      case 'easy':
        monedasBase = 10;
        break;
      case 'normal':
        monedasBase = 15;
        break;
      case 'dificil':
      case 'hard':
        monedasBase = 25;
        break;
      default:
        monedasBase = 5;
        break;
    }
    return (monedasBase + (puntuacion / 10).floor()).clamp(1, 100);
  }

  static Future<void> guardarPuntuacion(
      String gameNameIdentifier, int puntuacion, String usuario, String dificultad) async {
    final prefs = await SharedPreferences.getInstance();

    // Normalize difficulty to lowercase and without accents for SAVING
    String normalizedDificultad = dificultad.toLowerCase();
    normalizedDificultad = normalizedDificultad.replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');

    debugPrint('CurrencyManager: [SAVE] Attempting to save score:'); // Translated
    debugPrint('  Game ID: "$gameNameIdentifier"');
    debugPrint('  User: "$usuario"');
    debugPrint('  Difficulty (normalized and without accent for saving): "$normalizedDificultad"'); // Translated
    debugPrint('  Score: $puntuacion');

    int currentTotalPuntuacion = prefs.getInt('$_totalPuntuacionAcumuladaKeyPrefix$usuario') ?? 0;
    await prefs.setInt('$_totalPuntuacionAcumuladaKeyPrefix$usuario', currentTotalPuntuacion + puntuacion);
    debugPrint('  -> Total Accumulated Score for $usuario: ${currentTotalPuntuacion + puntuacion}'); // Translated

    int currentJuegosCompletados = prefs.getInt('$_juegosCompletadosKeyPrefix$usuario') ?? 0;
    await prefs.setInt('$_juegosCompletadosKeyPrefix$usuario', currentJuegosCompletados + 1);
    debugPrint('  -> Games Completed for $usuario: ${currentJuegosCompletados + 1}'); // Translated

    String topScoresKey = '$_topScoresKeyPrefix${gameNameIdentifier}_${usuario}_$normalizedDificultad';
    debugPrint('  -> SharedPreferences key to save: "$topScoresKey"'); // Translated

    List<String> scoresString = prefs.getStringList(topScoresKey) ?? [];
    List<int> currentScores = scoresString.map(int.parse).toList();

    currentScores.add(puntuacion);
    currentScores.sort((b, a) => a.compareTo(b));
    
    List<int> top5Scores = currentScores.take(5).toList();
    await prefs.setStringList(topScoresKey, top5Scores.map((e) => e.toString()).toList());
    debugPrint('  -> Individual scores saved: $top5Scores'); // Translated
  }

  static Future<int> getJuegosCompletados(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_juegosCompletadosKeyPrefix$usuario') ?? 0;
  }

  static Future<int> getTotalPuntuacionAcumuladaUsuario(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_totalPuntuacionAcumuladaKeyPrefix$usuario') ?? 0;
  }

  static Future<List<int>> obtenerLasCincoMejoresPuntuacionesPorJuego(
      String usuario, String gameNameIdentifier) async {
    final prefs = await SharedPreferences.getInstance();
    List<int> allScoresForGame = [];

    debugPrint('CurrencyManager: [LOAD] Attempting to get CONSOLIDATED scores for:'); // Translated
    debugPrint('  Game ID: "$gameNameIdentifier"');
    debugPrint('  User: "$usuario"');

    for (String difficulty in knownDifficulties) {
      String key = '$_topScoresKeyPrefix${gameNameIdentifier}_${usuario}_$difficulty';
      List<String> scoresString = prefs.getStringList(key) ?? [];
      List<int> scoresForDifficulty = scoresString.map(int.parse).toList();
      
      if (scoresForDifficulty.isNotEmpty) {
        debugPrint('  -> Found ${scoresForDifficulty.length} scores for difficulty "$difficulty" (key: "$key")'); // Translated
        allScoresForGame.addAll(scoresForDifficulty);
      } else {
        debugPrint('  No scores found for difficulty "$difficulty" (key: "$key")'); // Translated
      }
    }

    allScoresForGame.sort((b, a) => a.compareTo(b));
    List<int> top5 = allScoresForGame.take(5).toList();
    debugPrint('CurrencyManager: Final consolidated top 5: $top5'); // Translated
    return top5;
  }

  static Future<void> clearIndividualScores(String gameNameIdentifier, String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('CurrencyManager: Clearing individual scores for "$gameNameIdentifier" of "$usuario"...'); // Translated
    for (String difficulty in knownDifficulties) {
      String key = '$_topScoresKeyPrefix${gameNameIdentifier}_${usuario}_$difficulty';
      await prefs.remove(key);
      debugPrint('  Cleared key: "$key"'); // Translated
    }
  }

  // --- MODIFIED: Dispose method now closes the single StreamController ---
  static void dispose() {
    if (_isInitialized && !_monedasStreamController.isClosed) {
      _monedasStreamController.close();
      _isInitialized = false;
      debugPrint('CurrencyManager: Main coin stream disposed.');
    }
  }
}
