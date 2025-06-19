// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playmobil_app/currency_manager.dart'; // Import CurrencyManager
import 'package:playmobil_app/achievements.dart'; // IMPORTANT! Import AchievementManager
import 'dart:io'; // Needed to work with File
import 'package:image_picker/image_picker.dart'; // Import image_picker package
import 'package:flutter/foundation.dart'; // For debugPrint
import 'dart:async'; // For StreamSubscription

class ProfileScreen extends StatefulWidget {
  final String usuario;

  const ProfileScreen({super.key, required this.usuario});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Using a local state variable for statistics to update with setState
  Map<String, int> _estadisticas = {
    'totalJuegos': 0,
    'puntuacionTotal': 0,
    'logrosDesbloqueados': 0,
    'monedasActuales': 0,
  };

  List<Map<String, String>> _itemsComprados = [];
  String? _profileImagePath;

  // Stream subscriptions for real-time updates
  StreamSubscription? _monedasSubscription;
  StreamSubscription? _juegosCompletadosSubscription;
  StreamSubscription? _puntuacionAcumuladaSubscription;
  StreamSubscription? _logrosDesbloqueadosSubscription;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize CurrencyManager (already done in main.dart, but good practice if this screen is root)
    CurrencyManager.initialize();
    _loadProfileImage();
    _cargarItemsComprados(); // Load purchased items initially

    // Listen to coin changes from CurrencyManager
    _monedasSubscription = CurrencyManager.allMonedasStream.listen((monedasMap) {
      if (monedasMap.containsKey(widget.usuario)) {
        setState(() {
          _estadisticas['monedasActuales'] = monedasMap[widget.usuario]!;
          debugPrint('ProfileScreen: Monedas updated via stream: ${_estadisticas['monedasActuales']}');
        });
      }
    });

    // We need to extend CurrencyManager or AchievementManager to provide streams
    // for total games, total score, and achievements unlocked for real-time updates
    // for now, we'll keep calling _cargarEstadisticas() on resume and initial load.
    // However, to ensure they update without leaving the screen, we'd need streams for them too.
    // For this specific request, we'll focus on just loading them initially and on resume.
    _cargarEstadisticas(); // Initial load for all stats
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _monedasSubscription?.cancel(); // Cancel subscription to prevent memory leaks
    _juegosCompletadosSubscription?.cancel();
    _puntuacionAcumuladaSubscription?.cancel();
    _logrosDesbloqueadosSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When the app becomes active again, reload stats and purchased items
      // _cargarEstadisticas() will also trigger CurrencyManager.getMonedas which updates its stream.
      _cargarEstadisticas();
      _cargarItemsComprados();
    }
  }

  // --- _cargarEstadisticas FUNCTION MODIFIED for real-time consistency ---
  Future<void> _cargarEstadisticas() async {
    debugPrint('ProfileScreen: Starting statistics load for user: ${widget.usuario}');
    try {
      // Load total accumulated score from CurrencyManager
      final puntuacionTotalAcumulada = await CurrencyManager.getTotalPuntuacionAcumuladaUsuario(widget.usuario);
      debugPrint('ProfileScreen: Total Accumulated Score (read): $puntuacionTotalAcumulada');

      // Load unlocked achievements using AchievementManager
      final unlockedAchievementsList = await AchievementManager.getUnlockedAchievements(widget.usuario);
      final logrosDesbloqueadosCount = unlockedAchievementsList.length;
      debugPrint('ProfileScreen: Unlocked Achievements (read from AchievementManager): $logrosDesbloqueadosCount');

      // Load current coins from CurrencyManager. This call also ensures CurrencyManager stream is updated.
      await CurrencyManager.getMonedas(widget.usuario); // This will push the value to the stream.

      // Get total completed games directly from CurrencyManager
      final totalJuegosCompletadosReal = await CurrencyManager.getJuegosCompletados(widget.usuario);
      debugPrint('ProfileScreen: TOTAL Completed Games (read from CurrencyManager): $totalJuegosCompletadosReal');

      if (mounted) {
        setState(() {
          _estadisticas = {
            'totalJuegos': totalJuegosCompletadosReal,
            'puntuacionTotal': puntuacionTotalAcumulada,
            'logrosDesbloqueados': logrosDesbloqueadosCount,
            'monedasActuales': _estadisticas['monedasActuales']!, // Monedas are updated by the stream, keep its current value
          };
          debugPrint('ProfileScreen: Statistics UI state updated.');
        });
      }
    } catch (e) {
      debugPrint('ProfileScreen: ERROR loading statistics: $e');
    }
  }

  Future<void> _cargarItemsComprados() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final List<String> itemsDataStrings =
        prefs.getStringList('comprados_${widget.usuario}') ?? [];
    final List<Map<String, String>> loadedItems = [];

    debugPrint('ProfileScreen: Loading ${itemsDataStrings.length} purchased items for user: ${widget.usuario}');

    for (String itemDataString in itemsDataStrings) {
      final parts = itemDataString.split(';');
      if (parts.length == 2) {
        loadedItems.add({'nombre': parts[0], 'imagen': parts[1]});
        debugPrint('  - Loaded item: ${parts[0]} (${parts[1]})');
      } else {
        debugPrint('  - Skipping malformed item string: $itemDataString');
      }
    }

    if (mounted) {
      setState(() {
        _itemsComprados = loadedItems;
        debugPrint('ProfileScreen: Purchased items UI state updated. Total: ${_itemsComprados.length}');
      });
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _profileImagePath = prefs.getString('profile_image_${widget.usuario}');
    });
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_${widget.usuario}', image.path);
      if (!mounted) return;
      setState(() {
        _profileImagePath = image.path;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
    }
  }

  Future<void> _cambiarContrasena() async {
    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please, complete all fields')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final usuarios = prefs.getStringList('usuarios') ?? [];
    final contrasenas = prefs.getStringList('contrasenas') ?? [];

    final index = usuarios.indexOf(widget.usuario);
    if (index != -1) {
      contrasenas[index] = _newPasswordController.text;
      await prefs.setStringList('contrasenas', contrasenas);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );

      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
        title: const Text(
          'My Profile!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/playmobil_perfil_fondo.png",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap:
                            _pickProfileImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              _profileImagePath != null &&
                                      _profileImagePath!.isNotEmpty
                                  ? FileImage(
                                      File(_profileImagePath!),
                                    )
                                  : null,
                          child:
                              _profileImagePath == null ||
                                      _profileImagePath!.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.usuario,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Statistics!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatTile(
                        'Games Played',
                        _estadisticas['totalJuegos'].toString(),
                        Icons.sports_esports,
                        Colors.blue,
                      ),
                      const Divider(),
                      _buildStatTile(
                        'Total Score',
                        _estadisticas['puntuacionTotal'].toString(),
                        Icons.stars,
                        Colors.amber,
                      ),
                      const Divider(),
                      _buildStatTile(
                        'Achievements Unlocked',
                        _estadisticas['logrosDesbloqueados'].toString(),
                        Icons.emoji_events,
                        Colors.green,
                      ),
                      const Divider(),
                      _buildStatTile(
                        'My Coins',
                        _estadisticas['monedasActuales'].toString(),
                        Icons.monetization_on,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // --- NUEVA SECCIÓN: Mis Artículos Comprados ---
              if (_itemsComprados.isNotEmpty)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Purchased Items!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double availableWidth = constraints.maxWidth;
                            const double itemWidth = 100; // Desired width for each item in the grid
                            const double spacing = 10; // Spacing between items

                            int crossAxisCount = (availableWidth / (itemWidth + spacing)).floor();
                            if (crossAxisCount < 1) crossAxisCount = 1; // Ensure at least 1 column

                            double childAspectRatio = itemWidth / (itemWidth + 40); // Adjust ratio based on image + text height

                            return GridView.builder(
                              shrinkWrap: true, // Important to make GridView take only needed height
                              physics: const NeverScrollableScrollPhysics(), // Prevent GridView from scrolling independently
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                                childAspectRatio: childAspectRatio,
                              ),
                              itemCount: _itemsComprados.length,
                              itemBuilder: (context, index) {
                                final item = _itemsComprados[index];
                                return Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.grey.shade200, // Light background for the image
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: item['imagen']!.isNotEmpty
                                              ? Image.asset(
                                                  item['imagen']!,
                                                  fit: BoxFit.contain, // Use contain to fit without cropping
                                                  errorBuilder: (context, error, stackTrace) {
                                                    debugPrint('Error loading image ${item['imagen']}: $error');
                                                    return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                                                  },
                                                )
                                              : const Icon(Icons.shopping_bag, size: 50, color: Colors.grey), // Placeholder
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['nombre']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Change My Password!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cambiarContrasena,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Update Password!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
