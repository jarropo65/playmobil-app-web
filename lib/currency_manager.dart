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

  // --- NEW: StreamController for real-time coin updates ---
  // A map to hold StreamControllers for each user. This makes it scalable for multiple users.
  static final Map<String, StreamController<int>> _monedasStreamControllers = {};

  // Method to get the Stream of coins for a specific user
  static Stream<int> getMonedasStream(String usuario) {
    if (!_monedasStreamControllers.containsKey(usuario)) {
      _monedasStreamControllers[usuario] = StreamController<int>.broadcast();
      // Load initial coins for this user and add to stream
      _cargarMonedasIniciales(usuario);
    }
    return _monedasStreamControllers[usuario]!.stream;
  }

  // Private method to load initial coins and add to the stream
  static Future<void> _cargarMonedasIniciales(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final int initialMonedas = prefs.getInt('$_monedasKeyPrefix$usuario') ?? 0;
    _monedasStreamControllers[usuario]?.add(initialMonedas);
    debugPrint('CurrencyManager: Loaded initial coins for $usuario: $initialMonedas');
  }

  // Helper method to notify all listeners (through the stream) about coin changes
  static void _notificarCambioMonedas(String usuario, int nuevoTotal) {
    _monedasStreamControllers[usuario]?.add(nuevoTotal);
    debugPrint('CurrencyManager: Notified new coin total for $usuario: $nuevoTotal');
  }

  // --- MODIFIED: getMonedas now also triggers a stream update on load ---
  static Future<int> getMonedas(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final int currentMonedas = prefs.getInt('$_monedasKeyPrefix$usuario') ?? 0;
    // Also ensure the stream is initialized and updated with the current value
    _notificarCambioMonedas(usuario, currentMonedas);
    return currentMonedas;
  }

  // --- MODIFIED: addMonedas now notifies listeners ---
  static Future<void> addMonedas(int cantidad, String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    int currentMonedas = prefs.getInt('$_monedasKeyPrefix$usuario') ?? 0;
    int newTotal = currentMonedas + cantidad;
    await prefs.setInt('$_monedasKeyPrefix$usuario', newTotal);
    debugPrint('CurrencyManager: Added $cantidad coins to $usuario. Total: $newTotal');
    _notificarCambioMonedas(usuario, newTotal); // Notify listeners
  }

  // --- MODIFIED: gastarMonedas now notifies listeners ---
  static Future<bool> gastarMonedas(int cantidad, String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    int currentMonedas = prefs.getInt('$_monedasKeyPrefix$usuario') ?? 0;

    if (currentMonedas >= cantidad) {
      int newTotal = currentMonedas - cantidad;
      await prefs.setInt('$_monedasKeyPrefix$usuario', newTotal);
      debugPrint('CurrencyManager: Spent $cantidad coins from $usuario. Remaining: $newTotal');
      _notificarCambioMonedas(usuario, newTotal); // Notify listeners
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

  // --- NEW: Dispose method for StreamControllers to prevent memory leaks ---
  static void dispose() {
    _monedasStreamControllers.values.forEach((controller) => controller.close());
    _monedasStreamControllers.clear();
    debugPrint('CurrencyManager: All coin streams disposed.');
  }
}
