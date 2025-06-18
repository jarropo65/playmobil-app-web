import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/scores_screen.dart';
import 'screens/store_screen.dart';
import 'puzzle_game.dart';
import 'word_search_game.dart';
import 'word_game.dart';
import 'screens/profile_screen.dart';
import 'achievements.dart'; // Maintain import, even if not directly used here
import 'screens/reading_comprehension_screen.dart';
import 'screens/comic_game_screen.dart';
import 'screens/game_selection_screen.dart'; // IMPORTANT! Import of the new game selection screen
import 'package:auto_size_text/auto_size_text.dart'; // <--- NUEVA IMPORTACIÓN

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    // This is the build method for LoginPageState
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
              // Navigate to the Login screen and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.65,
                ),
                child: Image.asset(
                  'assets/images/logo/playmobil_logo.png',
                  height: 150,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
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
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
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
                ],
              ),
            ),
          ],
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
    _cargarPuntos();
  }

  Future<void> _cargarPuntos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _puntos = prefs.getInt('monedas_${widget.usuario}') ?? 0;
    });
  }

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
    // Calculamos el factor de aspecto de los elementos del GridView de forma dinámica
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double childAspectRatio = 1.0; // Valor por defecto

    // Ajustamos el childAspectRatio en base al textScaleFactor.
    // Una relación más pequeña (ej. 0.8) significa que el alto es mayor que el ancho.
    // Esto da más espacio vertical a los elementos de la cuadrícula.
    if (textScaleFactor > 1.3) { // Para tamaños de visualización muy grandes
      childAspectRatio = 0.7; // Hacemos los elementos más altos
    } else if (textScaleFactor > 1.1) { // Para tamaños de visualización grandes
      childAspectRatio = 0.85; // Hacemos los elementos ligeramente más altos
    } else if (textScaleFactor < 0.9) { // Para tamaños de visualización pequeños
      childAspectRatio = 1.1; // Hacemos los elementos un poco más anchos/menos altos
    } else {
      childAspectRatio = 1.0; // Estándar
    }

    // Una alternativa es basarse directamente en el ancho del dispositivo
    // final double screenWidth = MediaQuery.of(context).size.width;
    // if (screenWidth < 360) { // Dispositivos muy estrechos
    //   childAspectRatio = 0.7;
    // } else if (screenWidth < 600) { // Teléfonos estándar
    //   childAspectRatio = 0.8;
    // }


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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: childAspectRatio, // <--- APLICAMOS EL childAspectRatio DINÁMICO
            children: [
              _buildGameOption(context, 'Play', 'play_icon.png', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GameSelectionScreen(usuario: widget.usuario),
                  ),
                );
              }),
              _buildGameOption(context, 'Store', 'store_icon.png', () async {
                final prefs = await SharedPreferences.getInstance();
                final puntos = prefs.getInt('monedas_${widget.usuario}') ?? 0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoreScreen(
                      usuario: widget.usuario,
                      puntos: puntos,
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
              final prefs = await SharedPreferences.getInstance();
              final puntos = prefs.getInt('monedas_${widget.usuario}') ?? 0;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoreScreen(
                    usuario: widget.usuario,
                    puntos: puntos,
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
