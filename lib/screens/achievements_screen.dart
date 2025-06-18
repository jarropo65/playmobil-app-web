// lib/screens/achievements_screen.dart
import 'package:flutter/material.dart';
import '../achievements.dart'; // Ensure the path is correct

class AchievementsScreen extends StatefulWidget {
  final String usuario; // IMPORTANT! We add the user parameter

  const AchievementsScreen({super.key, required this.usuario}); // Mark as required

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

// Removed 'with SingleTickerProviderStateMixin' as it's not being used.
class _AchievementsScreenState extends State<AchievementsScreen> {
  bool _isLoading = true;
  List<Achievement> _allGameAchievements = []; // Stores all available achievements
  Set<String> _unlockedAchievementIds = {}; // Stores the IDs of achievements unlocked by the user

  @override
  void initState() {
    super.initState();
    _cargarLogros();
  }

  Future<void> _cargarLogros() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Step 1: Get all achievements defined in AchievementManager
      _allGameAchievements = AchievementManager.allAchievements;

      // Step 2: Get the IDs of the achievements that the current user has unlocked
      List<String> unlockedIdsList = await AchievementManager.getUnlockedAchievements(widget.usuario);
      _unlockedAchievementIds = unlockedIdsList.toSet(); // Convert to Set for efficient lookups

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading achievements: $e'); // Translated
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading achievements. Please try again.'), // Translated
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hall of Fame!', // Translated
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Layer 1: Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/playmobil_logros_fondo.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Layer 2: Content (Loading indicator or Achievements List)
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _allGameAchievements.isEmpty // If no achievements are defined in total
                  ? Center(
                      child: Container(
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
                        child: const Text(
                          'No achievements defined in the system.', // Translated
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _allGameAchievements.length,
                          itemBuilder: (context, index) {
                            final achievement = _allGameAchievements[index];
                            final isUnlocked = _unlockedAchievementIds.contains(achievement.id); // Determine if unlocked

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
                              color: Colors.white.withOpacity(0.85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                              child: ListTile(
                                // KEY CHANGE: We use .title and .description
                                title: Text(
                                  achievement.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  achievement.description,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                leading: CircleAvatar(
                                  radius: 22,
                                  // KEY CHANGE: We use isUnlocked here
                                  backgroundColor: isUnlocked ? Colors.amber[700] : Colors.grey[400],
                                  child: Icon(
                                    // KEY CHANGE: We use isUnlocked here
                                    isUnlocked ? Icons.star : Icons.lock,
                                    color: isUnlocked ? Colors.white : Colors.white70,
                                    size: 24,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}
