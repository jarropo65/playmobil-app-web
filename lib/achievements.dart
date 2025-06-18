// lib/achievements.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:playmobil_app/currency_manager.dart'; // To access CurrencyManager statistics

// Class to represent an Achievement
class Achievement {
  final String id; // Unique achievement identifier (e.g., 'first_game')
  final String title; // Achievement title (e.g., 'First Explorer')
  final String description; // Achievement description
  final String iconAsset; // Path to the icon asset (e.g., 'assets/icons/trophy.png')
  final int requiredValue; // Numeric value or threshold for the achievement (e.g., 10 games, 500 points)
  final AchievementType type; // Achievement type (e.g., total_score, games_completed)
  final String? difficulty; // Optional: For difficulty-based achievements (e.g., 'easy', 'hard')
  final String? gameId; // Optional: For specific game achievements (e.g., 'reading_comprehension')


  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.requiredValue,
    required this.type,
    this.difficulty, // Make it optional
    this.gameId, // Make it optional
  });
}

// Enum for different achievement types
enum AchievementType {
  gamesCompletedOverall, // Based on the total number of games completed (any difficulty)
  totalScore, // Based on the total accumulated score
  coinsCollected, // Based on the total coins collected
  gamesCompletedByDifficulty, // Based on games completed at a specific difficulty
  specificGameCompleted, // Based on completing a specific game (independent of difficulty if the game doesn't have one)
}

class AchievementManager {
  // List of all available achievements in the game
  // You can expand this list with more achievements and different conditions
  static final List<Achievement> allAchievements = [
    // Achievements for Games Completed (Overall)
    const Achievement(
      id: 'primer_paso',
      title: 'First Step', // Translated
      description: 'Complete your first game (any difficulty).', // Translated
      iconAsset: 'assets/images/icons/achievements_icon.png', // ADJUSTED
      requiredValue: 1,
      type: AchievementType.gamesCompletedOverall,
    ),
    const Achievement(
      id: 'explorador_novato',
      title: 'Novice Explorer', // Translated
      description: 'Complete 5 games (total).', // Translated
      iconAsset: 'assets/images/icons/achievements_icon.png', // ADJUSTED
      requiredValue: 5,
      type: AchievementType.gamesCompletedOverall,
    ),
    const Achievement(
      id: 'aventurero_incansable',
      title: 'Relentless Adventurer', // Translated
      description: 'Complete 10 games (total).', // Translated
      iconAsset: 'assets/images/icons/achievements_icon.png', // ADJUSTED
      requiredValue: 10,
      type: AchievementType.gamesCompletedOverall,
    ),

    // Achievements for Difficulty Mastery
    const Achievement(
      id: 'maestro_facil',
      title: 'Easy Master', // Translated
      description: 'Complete 3 different games on EASY difficulty.', // Translated
      iconAsset: 'assets/images/icons/achievements_icon.png', // ADJUSTED
      requiredValue: 3,
      type: AchievementType.gamesCompletedByDifficulty,
      difficulty: 'facil', // Keep as 'facil' as it's an internal key, not a displayed string
    ),
    const Achievement(
      id: 'maestro_dificil',
      title: 'Hard Master', // Translated
      description: 'Complete 3 different games on HARD difficulty.', // Translated
      iconAsset: 'assets/images/icons/achievements_icon.png', // ADJUSTED
      requiredValue: 3,
      type: AchievementType.gamesCompletedByDifficulty,
      difficulty: 'dificil', // Keep as 'dificil' as it's an internal key, not a displayed string
    ),

    // Achievements for Total Accumulated Score
    const Achievement(
      id: 'gran_puntuador',
      title: 'Grand Scorer', // Translated
      description: 'Accumulate a total of 1000 points.', // Translated
      iconAsset: 'assets/images/icons/achievements_icon.png', // ADJUSTED
      requiredValue: 1000,
      type: AchievementType.totalScore,
    ),
    const Achievement(
      id: 'maestro_de_puntos',
      title: 'Points Master', // Translated
      description: 'Accumulate a total of 5000 points.', // Translated
      iconAsset: 'assets/images/icons/achievements_icon.png', // ADJUSTED
      requiredValue: 5000,
      type: AchievementType.totalScore,
    ),

    // Achievements for Coins Collected
    const Achievement(
      id: 'cazador_de_monedas',
      title: 'Coin Hunter', // Translated
      description: 'Collect a total of 50 coins.', // Translated
      iconAsset: 'assets/images/icons/achievements_icon.png', // ADJUSTED
      requiredValue: 50,
      type: AchievementType.coinsCollected,
    ),
    const Achievement(
      id: 'tesoro_escondido',
      title: 'Hidden Treasure', // Translated
      description: 'Collect a total of 200 coins.', // Translated
      iconAsset: 'assets/images/icons/achievements_icon.png', // ADJUSTED
      requiredValue: 200,
      type: AchievementType.coinsCollected,
    ),

    // Specific Achievement for Reading Comprehension
    const Achievement(
      id: 'lector_brillante',
      title: 'Brilliant Reader', // Translated
      description: 'Complete the Reading Comprehension game.', // Translated
      iconAsset: 'assets/images/icons/reading_icon.png', // ADJUSTED (using reading icon if suitable)
      requiredValue: 1, // Fulfilled at least once
      type: AchievementType.specificGameCompleted,
      gameId: 'comprension_lectora',
    ),
  ];

  // Prefix for SharedPreferences keys where we save unlocked achievements
  static const String _achievementsUnlockedKeyPrefix = 'achievements_unlocked_';
  // Prefix for tracking games completed by difficulty and game
  static const String _gamesCompletedByDifficultyPrefix = 'games_completed_by_difficulty_';
  static const String _gamesCompletedSpecificGamePrefix = 'games_completed_specific_game_';


  // Gets the IDs of unlocked achievements for a specific user
  static Future<List<String>> getUnlockedAchievements(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_achievementsUnlockedKeyPrefix$usuario') ?? [];
  }

  // Unlocks an achievement for a user and saves it in SharedPreferences
  static Future<void> _unlockAchievement(String usuario, String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> unlocked = prefs.getStringList('$_achievementsUnlockedKeyPrefix$usuario') ?? [];
    if (!unlocked.contains(achievementId)) {
      unlocked.add(achievementId);
      await prefs.setStringList('$_achievementsUnlockedKeyPrefix$usuario', unlocked);
      debugPrint('AchievementManager: Achievement unlocked for $usuario: $achievementId'); // Translated
      // Here you could add logic to show a notification in the UI
      // For example, using an Overlay or Navigator.overlay
    } else {
      debugPrint('AchievementManager: Achievement $achievementId was already unlocked for $usuario.'); // Translated
    }
  }

  // Method to record that a game has been completed at a specific difficulty
  static Future<void> _recordGameCompletion(String usuario, String gameId, String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    // Normalize the difficulty (e.g., remove accents)
    final String normalizedDifficulty = difficulty.toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
    final String key = '$_gamesCompletedByDifficultyPrefix${usuario}_${gameId}_$normalizedDifficulty';
    await prefs.setBool(key, true); // Simply mark as completed
    debugPrint('AchievementManager: Recorded game completed: $gameId on $normalizedDifficulty difficulty for $usuario.'); // Translated

    // For specific game achievement (like Reading Comprehension)
    final String specificGameKey = '$_gamesCompletedSpecificGamePrefix${usuario}_$gameId';
    await prefs.setBool(specificGameKey, true);
    debugPrint('AchievementManager: Recorded specific game completed: $gameId for $usuario.'); // Translated
  }

  // Checks and unlocks achievements after each game or when loading the profile
  static Future<void> verificarLogros(String usuario, String gameNameIdentifier, String gameDifficulty, int puntuacionJuego) async {
    debugPrint('AchievementManager: Checking achievements for user: $usuario (game: $gameNameIdentifier, difficulty: $gameDifficulty, score: $puntuacionJuego)'); // Translated

    // Step 1: Record game completion for difficulty/specific game achievements
    // Normalize difficulty for recording
    final String normalizedGameDifficulty = gameDifficulty.toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
    await _recordGameCompletion(usuario, gameNameIdentifier, normalizedGameDifficulty);


    // Step 2: Load current user statistics
    int totalJuegosCompletados = await CurrencyManager.getJuegosCompletados(usuario);
    int puntuacionTotalAcumulada = await CurrencyManager.getTotalPuntuacionAcumuladaUsuario(usuario);
    int monedasActuales = await CurrencyManager.getMonedas(usuario);

    // Step 3: Verify each achievement
    for (var achievement in allAchievements) {
      bool unlocked = false;
      bool alreadyUnlocked = (await getUnlockedAchievements(usuario)).contains(achievement.id);

      if (alreadyUnlocked) {
        debugPrint('AchievementManager: Achievement ${achievement.id} already unlocked. Skipping verification.'); // Translated
        continue; // Do not verify if already unlocked
      }

      switch (achievement.type) {
        case AchievementType.gamesCompletedOverall:
          if (totalJuegosCompletados >= achievement.requiredValue) {
            unlocked = true;
          }
          break;
        case AchievementType.totalScore:
          if (puntuacionTotalAcumulada >= achievement.requiredValue) {
            unlocked = true;
          }
          break;
        case AchievementType.coinsCollected:
          if (monedasActuales >= achievement.requiredValue) {
            unlocked = true;
          }
          break;
        case AchievementType.gamesCompletedByDifficulty:
          if (achievement.difficulty != null) {
            // Count how many different games have been completed on this difficulty
            final prefs = await SharedPreferences.getInstance();
            int count = 0;
            // We need a list of ALL gameIds to iterate, not just the current one.
            // To simplify, we will assume that the gameIds that use difficulties are:
            // Ensure this list reflects the IDs of your games that have difficulties
            List<String> gamesWithDifficulties = ['memoria', 'puzzle', 'sopa_de_letras', 'word_game', 'comic_game'];
            for (String gameId in gamesWithDifficulties) {
              final String key = '$_gamesCompletedByDifficultyPrefix${usuario}_${gameId}_${achievement.difficulty!}';
              if (prefs.getBool(key) ?? false) {
                count++;
              }
            }
            if (count >= achievement.requiredValue) {
              unlocked = true;
            }
          }
          break;
        case AchievementType.specificGameCompleted:
          if (achievement.gameId != null) {
            final prefs = await SharedPreferences.getInstance();
            final String key = '$_gamesCompletedSpecificGamePrefix${usuario}_${achievement.gameId!}';
            if (prefs.getBool(key) ?? false) {
              unlocked = true;
            }
          }
          break;
      }

      if (unlocked) {
        await _unlockAchievement(usuario, achievement.id);
      }
    }
    debugPrint('AchievementManager: Achievement verification completed for $usuario.'); // Translated
  }

  // Method to clear all achievements for a user (for debugging)
  static Future<void> clearAchievements(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_achievementsUnlockedKeyPrefix$usuario');
    // Also clear records of games completed by difficulty and specific game
    // Ensure this list reflects the IDs of your games that have difficulties
    List<String> allGameIds = ['memoria', 'puzzle', 'sopa_de_letras', 'word_game', 'comic_game', 'comprension_lectora'];
    
    for (String gameId in allGameIds) {
      // Clear records by difficulty
      for (String difficulty in CurrencyManager.knownDifficulties) { // Use difficulties from CurrencyManager
        String normalizedDifficulty = difficulty.toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
        await prefs.remove('$_gamesCompletedByDifficultyPrefix${usuario}_${gameId}_$normalizedDifficulty');
      }
      // Clear specific game record
      await prefs.remove('$_gamesCompletedSpecificGamePrefix${usuario}_$gameId');
    }
    debugPrint('AchievementManager: Achievements and game completion records cleared for user: $usuario'); // Translated
  }
}
