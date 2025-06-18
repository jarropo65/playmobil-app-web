// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart'; // Mantener si se usa en GameSelectionScreen
import 'screens/achievements_screen.dart';
import 'screens/scores_screen.dart';
import 'screens/store_screen.dart';
import 'puzzle_game.dart'; // Mantener si se usa en GameSelectionScreen
import 'word_search_game.dart'; // Mantener si se usa en GameSelectionScreen
import 'word_game.dart'; // Mantener si se usa en GameSelectionScreen
import 'screens/profile_screen.dart';
import 'achievements.dart'; // Maintain import, even if not directly used here
import 'screens/reading_comprehension_screen.dart'; // Mantener si se usa en GameSelectionScreen
import 'screens/comic_game_screen.dart'; // Mantener si se usa en GameSelectionScreen
import 'screens/game_selection_screen.dart'; // IMPORTANT! Import of the new game selection screen
import 'package:auto_size_text/auto_size_text.dart';

// --- NUEVO: Importar CurrencyManager ---
import 'currency_manager.dart';

void main() {
  // Asegurarse de que Flutter esté inicializado antes de usar WidgetsBinding.
  // Esto es vital para SharedPreferences y para añadir el observer.
  WidgetsFlutterBinding.ensureInitialized();

  // --- NUEVO: Inicializar CurrencyManager aquí, una única vez al inicio de la app ---
  CurrencyManager.initialize();

  runApp(const MyApp());
}

// --- MODIFICACION: MyApp ahora es un StatefulWidget ---
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Añadir este observer para saber cuándo la aplicación cambia de estado (ej. se cierra).
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Cuando la aplicación se cierra permanentemente, cerramos el StreamController
    // de CurrencyManager para liberar recursos y evitar fugas de memoria.
    WidgetsBinding.instance.removeObserver(this);
    CurrencyManager.dispose(); // <-- ¡Llamar a dispose aquí para el CurrencyManager!
    super.dispose();
  }

  // didChangeAppLifecycleState es útil para reanudar operaciones cuando la app vuelve a primer plano.
  // En este caso, ya el StreamBuilder en StoreScreen se encarga de reaccionar a los cambios.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Opcional: Forzar una actualización del saldo de monedas en el stream
      // Esto es una capa extra de seguridad para asegurar que el stream emita
      // el valor más reciente de SharedPreferences si la app estuvo inactiva.
      // CurrencyManager.getMonedas('current_user'); // Necesitarías el usuario actual si no lo pasas por aquí.
      // Sin embargo, StoreScreen ya lo llama en su initState/didChangeAppLifecycleState.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playmobil App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FB4F8),
          primary: const Color(0xFF4FB4F8),
          secondary: const Color(0xFF7ED957),
          tertiary: const Color(0xFFFFD93D),
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(elevation: 4, margin: EdgeInsets.all(8)),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF4FB4F8),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  Future<void> _iniciarSesion() async {
    if (!mounted) return;

    if (_usuarioController.text.isEmpty || _contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please, complete all fields')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final usuarios = prefs.getStringList('usuarios') ?? [];
    final contrasenas = prefs.getStringList('contrasenas') ?? [];

    if (!mounted) return;

    final index = usuarios.indexOf(_usuarioController.text);
    if (index != -1 && contrasenas[index] == _contrasenaController.text) {
      await prefs.setString('currentUser', _usuarioController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(usuario: _usuarioController.text),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect username or password')),
      );
    }
  }

  Future<void> _registrarUsuario() async {
    if (!mounted) return;
    if (_usuarioController.text.isEmpty || _contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please, complete all fields')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final usuarios = prefs.getStringList('usuarios') ?? [];
    final contrasenas = prefs.getStringList('contrasenas') ?? [];

    if (usuarios.contains(_usuarioController.text)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User already exists')));
      return;
    }

    usuarios.add(_usuarioController.text);
    contrasenas.add(_contrasenaController.text);

    await prefs.setStringList('usuarios', usuarios);
    await prefs.setStringList('contrasenas', contrasenas);
    await prefs.setString('currentUser', _usuarioController.text);
    await prefs.setInt('monedas_${_usuarioController.text}', 0);
    await prefs.setStringList(
      'puntuaciones_memoria_${_usuarioController.text}',
      [],
    );
    await prefs.setStringList(
      'puntuaciones_puzzle_${_usuarioController.text}',
      [],
    );
    await prefs.setStringList(
      'puntuaciones_sopa de letras_${_usuarioController.text}',
      [],
    );
    await prefs.setStringList(
      'puntuaciones_word_${_usuarioController.text}',
      [],
    );
    await prefs.setStringList(
      'puntuaciones_comprension_lectora_${_usuarioController.text}',
      [],
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User registered successfully')),
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomePage(usuario: _usuarioController.text),
      ),
    );
  }

  void _mostrarModalInicioSesion() {
    _usuarioController.clear();
    _contrasenaController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Log In!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _iniciarSesion();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Enter!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarModalRegistro() {
    _usuarioController.clear();
    _contrasenaController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'User Registration!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'New Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_add),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registrarUsuario,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Register!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MODIFICACION AQUI: Para que la LoginPage sea responsiva
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/backgrounds/main_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navegar a la pantalla de inicio de sesión y eliminar todas las rutas anteriores
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        body: Center( // Usamos Center para centrar el contenido principal
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente los hijos
            children: [
              // Logo de Playmobil
              Flexible( // Flexible para que la imagen se adapte
                flex: 3, // Ocupa un poco más de espacio
                child: Image.asset(
                  'assets/images/logo/playmobil_logo.png',
                  height: MediaQuery.of(context).size.height * 0.35, // Altura relativa a la pantalla
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40), // Espacio entre el logo y los botones
              // Botones de inicio de sesión/registro
              Flexible( // Flexible para que los botones se adapten
                flex: 1, // Ocupa menos espacio que la imagen
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                    children: [
                      Expanded( // Botones expandidos para tomar el espacio disponible
                        child: ElevatedButton.icon(
                          onPressed: _mostrarModalInicioSesion,
                          icon: const Icon(Icons.login, color: Colors.white),
                          label: const Text(
                            'Log In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded( // Botones expandidos para tomar el espacio disponible
                        child: ElevatedButton.icon(
                          onPressed: _mostrarModalRegistro,
                          icon: const Icon(Icons.person_add, color: Colors.white),
                          label: const Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Añadir un Spacer si se quiere empujar el contenido hacia el centro o arriba/abajo
              // Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}

class HomePage extends StatefulWidget {
  final String usuario;
  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _puntos = 0;

  @override
  void initState() {
    super.initState();
    // No longer need to call _cargarPuntos() from SharedPreferences here,
    // as we will use the CurrencyManager stream directly.
    // _cargarPuntos(); // REMOVED

    // --- NEW: Listen to the CurrencyManager stream for the current user's coins ---
    CurrencyManager.allMonedasStream.listen((monedasMap) {
      if (monedasMap.containsKey(widget.usuario)) {
        setState(() {
          _puntos = monedasMap[widget.usuario]!;
        });
      }
    });
    // Trigger an initial load to ensure the stream emits the current value
    CurrencyManager.getMonedas(widget.usuario);
  }

  // Future<void> _cargarPuntos() async { // REMOVED, now handled by stream
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _puntos = prefs.getInt('monedas_${widget.usuario}') ?? 0;
  //   });
  // }

  // Helper method to build game options in the GridView
  Widget _buildGameOption(
      BuildContext context,
      String title,
      String iconPath,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reducimos el tamaño del contenedor de la imagen para dar más espacio al texto
              SizedBox( // Usamos SizedBox para controlar el tamaño de la imagen.
                width: 70, // Tamaño del icono ajustado (originalmente 80)
                height: 70, // Tamaño del icono ajustado (originalmente 80)
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/icons/$iconPath',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Espacio reducido de 16 a 10
              Expanded( // Mantenemos Expanded para que el texto tome el espacio restante
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AutoSizeText(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28, // Aumentamos el tamaño base para mayor visibilidad
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    minFontSize: 14, // Tamaño mínimo de fuente para asegurar legibilidad
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build side menu (Drawer) items
  Widget _buildMenuItem(
      BuildContext context,
      String title,
      IconData icon,
      Color iconColor,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/backgrounds/main_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate to the Login screen and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          title: Text('Welcome, ${widget.usuario}!'),
          backgroundColor:
          Theme.of(context).colorScheme.primary.withOpacity(0.8),
        ),
        drawer: _buildDrawer(context), // Ensure the Drawer is built here
        body: LayoutBuilder( // Usamos LayoutBuilder para adaptar el GridView
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            int crossAxisCount = 2; // Por defecto para pantallas pequeñas

            if (screenWidth > 1200) {
              crossAxisCount = 4; // 4 columnas para pantallas muy grandes (escritorio grande)
            } else if (screenWidth > 800) {
              crossAxisCount = 3; // 3 columnas para tabletas o monitores medianos
            } else {
              crossAxisCount = 2; // 2 columnas para móviles o ventanas estrechas
            }

            // Ajustamos el childAspectRatio para que los elementos no sean ni muy anchos ni muy altos
            // Un valor más bajo hace el ítem más alto (útil para texto grande), un valor más alto lo hace más ancho.
            double childAspectRatio = 1.0;
            if (screenWidth < 600) { // Móviles
              childAspectRatio = 0.9; // Ligeramente más altos para mejor legibilidad en pantallas pequeñas
            } else if (screenWidth < 900) { // Tabletas en vertical
              childAspectRatio = 1.1; // Más anchos
            } else { // Escritorio
              childAspectRatio = 1.2; // Aún más anchos
            }


            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: crossAxisCount, // <-- APLICAMOS EL crossAxisCount DINÁMICO
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: childAspectRatio, // <-- APLICAMOS EL childAspectRatio DINÁMICO
                children: [
                  _buildGameOption(context, 'Play', 'play_icon.png', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        GameSelectionScreen(usuario: widget.usuario), // Pasa el usuario aquí
                      ),
                    );
                  }),
                  _buildGameOption(context, 'Store', 'store_icon.png', () async {
                    // No necesitas obtener puntos aquí, StoreScreen ahora usa el stream
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreScreen(
                          usuario: widget.usuario,
                          puntos: 0, // 'puntos' ya no es relevante en StoreScreen
                        ),
                      ),
                    );
                  }),
                  _buildGameOption(context, 'Scores', 'scores_icon.png', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScoresScreen(usuario: widget.usuario)),
                    );
                  }),
                  _buildGameOption(context, 'Achievements', 'achievements_icon.png', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          AchievementsScreen(usuario: widget.usuario),
                      ),
                    );
                  }),
                  _buildGameOption(context, 'Profile', 'profile_icon.png', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          ProfileScreen(usuario: widget.usuario),
                      ),
                    );
                  }),
                  _buildGameOption(context, 'Log Out', 'logout_icon.png', () {
                    // Option to log out
                    _cerrarSesion();
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hello, ${widget.usuario}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildMenuItem(
            context,
            'Profile',
            Icons.person,
            Theme.of(context).colorScheme.primary,
                () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(usuario: widget.usuario),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            'Store',
            Icons.store,
            Theme.of(context).colorScheme.secondary,
                () async {
              Navigator.pop(context); // Close the drawer
              // No necesitas obtener puntos aquí, StoreScreen ahora usa el stream
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoreScreen(
                    usuario: widget.usuario,
                    puntos: 0, // 'puntos' ya no es relevante en StoreScreen
                  ),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            'Scores',
            Icons.leaderboard,
            Colors.orange,
                () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ScoresScreen(usuario: widget.usuario)),
              );
            },
          ),
          _buildMenuItem(
            context,
            'Achievements',
            Icons.emoji_events,
            Colors.amber,
                () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AchievementsScreen(usuario: widget.usuario),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.grey.shade300),
          ),
          ListTile(
            leading: ImageIcon(
              const AssetImage(
                'assets/images/icons/logout_icon.png',
              ),
              color: Colors.redAccent,
              size: 24,
            ),
            title: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _cerrarSesion,
          ),
        ],
      ),
    );
  }

  void _cerrarSesion() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }
}
