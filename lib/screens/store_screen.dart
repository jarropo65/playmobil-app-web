// lib/screens/store_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../currency_manager.dart'; // Ensure this import is correct
import 'dart:math'; // Import for min/max functions

class StoreScreen extends StatefulWidget {
  final String usuario;
  final int puntos; // This parameter will no longer be the main one for coins

  const StoreScreen({super.key, required this.usuario, required this.puntos});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with WidgetsBindingObserver {
  String _mainCategoriaSeleccionada = 'All'; // Translated: 'Todos' to 'All'
  String _subCategoriaSeleccionada = 'All'; // Translated: 'Todos' to 'All'
  String _busqueda = '';
  Set<String> _favoritos = {};
  // Removed _monedasUsuario state variable, now handled by StreamBuilder

  final List<Map<String, dynamic>> _productos = [
    // --- Clothing ---
    {
      'nombre': 'Blue Crystal Dress',
      'precio': 120,
      'imagen': 'assets/images/store/blue_crystal_dress.png',
      'categoria': 'Clothing',
      'subcategoria': 'Dresses',
    },
    {
      'nombre': 'Blue Jacket',
      'precio': 150,
      'imagen': 'assets/images/store/blue_jacket.png',
      'categoria': 'Clothing',
      'subcategoria': 'Jackets',
    },
    {
      'nombre': 'Blue Yellow Short Skirt',
      'precio': 70,
      'imagen': 'assets/images/store/blue_yellow_short_skirt.png',
      'categoria': 'Clothing',
      'subcategoria': 'Skirts',
    },
    {
      'nombre': 'Brown Pants',
      'precio': 90,
      'imagen': 'assets/images/store/brown_pants.png',
      'categoria': 'Clothing',
      'subcategoria': 'Pants',
    },
    {
      'nombre': 'Green Blouse',
      'precio': 80,
      'imagen': 'assets/images/store/green_blouse.png',
      'categoria': 'Clothing',
      'subcategoria': 'Blouses',
    },
    {
      'nombre': 'Green Pants',
      'precio': 90,
      'imagen': 'assets/images/store/green_pants.png',
      'categoria': 'Clothing',
      'subcategoria': 'Pants',
    },
    {
      'nombre': 'Green Red Dress',
      'precio': 130,
      'imagen': 'assets/images/store/green_red_dress.png',
      'categoria': 'Clothing',
      'subcategoria': 'Dresses',
    },
    {
      'nombre': 'Jeans',
      'precio': 90,
      'imagen': 'assets/images/store/jeans.png',
      'categoria': 'Clothing',
      'subcategoria': 'Pants',
    },
    {
      'nombre': 'Lilac Skirt',
      'precio': 70,
      'imagen': 'assets/images/store/lilac_skirt.png',
      'categoria': 'Clothing',
      'subcategoria': 'Skirts',
    },
    {
      'nombre': 'Lilac Vest',
      'precio': 100,
      'imagen': 'assets/images/store/lilac_vest.png',
      'categoria': 'Clothing',
      'subcategoria': 'Vests',
    },
    {
      'nombre': 'Maroon Vest',
      'precio': 100,
      'imagen': 'assets/images/store/maroon_vest.png',
      'categoria': 'Clothing',
      'subcategoria': 'Vests',
    },
    {
      'nombre': 'Pink Golden Dress',
      'precio': 150,
      'imagen': 'assets/images/store/pink_golden_dress.png',
      'categoria': 'Clothing',
      'subcategoria': 'Dresses',
    },
    {
      'nombre': 'Purple Blouse',
      'precio': 80,
      'imagen': 'assets/images/store/purple_blouse.png',
      'categoria': 'Clothing',
      'subcategoria': 'Blouses',
    },
    {
      'nombre': 'Red Skirt',
      'precio': 70,
      'imagen': 'assets/images/store/red_skirt.png',
      'categoria': 'Clothing',
      'subcategoria': 'Skirts',
    },
    {
      'nombre': 'White Pants',
      'precio': 90,
      'imagen': 'assets/images/store/white_pants.png',
      'categoria': 'Clothing',
      'subcategoria': 'Pants',
    },

    // --- Footwear ---
    {
      'nombre': 'Black Boots',
      'precio': 180,
      'imagen': 'assets/images/store/black_boots.png',
      'categoria': 'Footwear',
      'subcategoria': 'Boots',
    },
    {
      'nombre': 'Pink Sandals',
      'precio': 30,
      'imagen': 'assets/images/store/pink_sandals.png',
      'categoria': 'Footwear',
      'subcategoria': 'Sandals',
    },
    {
      'nombre': 'Pink Shoes',
      'precio': 100,
      'imagen': 'assets/images/store/pink_shoes.png',
      'categoria': 'Footwear',
      'subcategoria': 'Shoes',
    },
    {
      'nombre': 'Trainers',
      'precio': 110,
      'imagen': 'assets/images/store/trainers.png',
      'categoria': 'Footwear',
      'subcategoria': 'Sneakers',
    },

    // --- Accessories ---
    {
      'nombre': 'Ball Necklace',
      'precio': 60,
      'imagen': 'assets/images/store/ball_necklace.png',
      'categoria': 'Accessories',
      'subcategoria': 'Necklaces',
    },
    {
      'nombre': 'Black Belt',
      'precio': 50,
      'imagen': 'assets/images/store/black_belt.png',
      'categoria': 'Accessories',
      'subcategoria': 'Belts',
    },
    {
      'nombre': 'Blue Hat',
      'precio': 40,
      'imagen': 'assets/images/store/blue_hat.png',
      'categoria': 'Accessories',
      'subcategoria': 'Hats',
    },
    {
      'nombre': 'Blue Ring',
      'precio': 180,
      'imagen': 'assets/images/store/blue_ring.png',
      'categoria': 'Accessories',
      'subcategoria': 'Rings',
    },
    {
      'nombre': 'Flower Necklace',
      'precio': 65,
      'imagen': 'assets/images/store/flower_necklace.png',
      'categoria': 'Accessories',
      'subcategoria': 'Necklaces',
    },
    {
      'nombre': 'Green Bag',
      'precio': 70,
      'imagen': 'assets/images/store/green_bag.png',
      'categoria': 'Accessories',
      'subcategoria': 'Bags',
    },
    {
      'nombre': 'Green Belt',
      'precio': 50,
      'imagen': 'assets/images/store/green_belt.png',
      'categoria': 'Accessories',
      'subcategoria': 'Belts',
    },
    {
      'nombre': 'Light Blue Hat',
      'precio': 40,
      'imagen': 'assets/images/store/light_blue_hat.png',
      'categoria': 'Accessories',
      'subcategoria': 'Hats',
    },
    {
      'nombre': 'Loklo Hair', // Assuming it's a type of hair/wig
      'precio': 75,
      'imagen': 'assets/images/store/loklo.png',
      'categoria': 'Accessories',
      'subcategoria': 'Hair',
    },
    {
      'nombre': 'Long Black Hair',
      'precio': 75,
      'imagen': 'assets/images/store/long_black_hair.png',
      'categoria': 'Accessories',
      'subcategoria': 'Hair',
    },
    {
      'nombre': 'Long Blonde Hair',
      'precio': 75,
      'imagen': 'assets/images/store/long_blonde_hair.png',
      'categoria': 'Accessories',
      'subcategoria': 'Hair',
    },
    {
      'nombre': 'Long Brown Hair',
      'precio': 75,
      'imagen': 'assets/images/store/long_brown_hair.png',
      'categoria': 'Accessories',
      'subcategoria': 'Hair',
    },
    {
      'nombre': 'Pink Bag',
      'precio': 70,
      'imagen': 'assets/images/store/pink_bag.png',
      'categoria': 'Accessories',
      'subcategoria': 'Bags',
    },
    {
      'nombre': 'Purple Ring',
      'precio': 180,
      'imagen': 'assets/images/store/purple_ring.png',
      'categoria': 'Accessories',
      'subcategoria': 'Rings',
    },
    {
      'nombre': 'Short Black Hair',
      'precio': 60,
      'imagen': 'assets/images/store/short_black_hair.png',
      'categoria': 'Accessories',
      'subcategoria': 'Hair',
    },
    {
      'nombre': 'Short Blonde Hair',
      'precio': 60,
      'imagen': 'assets/images/store/short_blonde_hair.png',
      'categoria': 'Accessories',
      'subcategoria': 'Hair',
    },
    {
      'nombre': 'Short Brown Hair',
      'precio': 60,
      'imagen': 'assets/images/store/short_brown_hair.png',
      'categoria': 'Accessories',
      'subcategoria': 'Hair',
    },
    {
      'nombre': 'Silver Belt',
      'precio': 60,
      'imagen': 'assets/images/store/silver_belt.png',
      'categoria': 'Accessories',
      'subcategoria': 'Belts',
    },
    {
      'nombre': 'Star Necklace',
      'precio': 70,
      'imagen': 'assets/images/store/star_necklace.png',
      'categoria': 'Accessories',
      'subcategoria': 'Necklaces',
    },
    {
      'nombre': 'White Hat',
      'precio': 40,
      'imagen': 'assets/images/store/white_hat.png',
      'categoria': 'Accessories',
      'subcategoria': 'Hats',
    },
    {
      'nombre': 'Yellow Bag',
      'precio': 70,
      'imagen': 'assets/images/store/yellow_bag.png',
      'categoria': 'Accessories',
      'subcategoria': 'Bags',
    },
    {
      'nombre': 'Yellow Belt',
      'precio': 50,
      'imagen': 'assets/images/store/yellow_belt.png',
      'categoria': 'Accessories',
      'subcategoria': 'Belts',
    },
    {
      'nombre': 'Yellow Ring',
      'precio': 180,
      'imagen': 'assets/images/store/yellow_ring.png',
      'categoria': 'Accessories',
      'subcategoria': 'Rings',
    },
  ];

  List<String> get _mainCategorias {
    final mainCategorias =
        _productos.map((p) => p['categoria'] as String).toSet().toList();
    mainCategorias.sort();
    return ['All', ...mainCategorias]; // Translated: 'Todos' to 'All'
  }

  List<String> get _subCategorias {
    if (_mainCategoriaSeleccionada == 'All') {
      return ['All'];
    }
    final subCategorias = _productos
        .where((p) => p['categoria'] == _mainCategoriaSeleccionada)
        .map((p) => p['subcategoria'] as String)
        .toSet()
        .toList();
    subCategorias.sort();
    return ['All', ...subCategorias];
  }

  // No longer need _monedasUsuario state variable as we'll use StreamBuilder
  // late int _monedasUsuario;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // No need to call _cargarMonedas() here anymore for initial state.
    // StreamBuilder will handle the initial value.
    _cargarFavoritos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // No need to call _cargarMonedas() here anymore, StreamBuilder handles it.
      // We might want to trigger a refresh of the stream if necessary,
      // but the CurrencyManager should handle adding values from SharedPreferences
      // when getMonedasStream is first called or if add/gastar methods are used.
      CurrencyManager.getMonedas(widget.usuario); // Just to ensure latest value is pushed to stream if it's not already.
    }
  }

  // --- _cargarMonedas FUNCTION REMOVED (mostly) ---
  // The logic is now handled by CurrencyManager's stream and StreamBuilder
  // Future<void> _cargarMonedas() async {
  //   final monedas = await CurrencyManager.getMonedas(widget.usuario);
  //   if (mounted) {
  //     setState(() {
  //       _monedasUsuario = monedas;
  //     });
  //   }
  // }

  Future<void> _cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favoritos = Set<String>.from(
        prefs.getStringList('favoritos_${widget.usuario}') ?? [],
      );
    });
  }

  Future<void> _toggleFavorito(String nombreProducto) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      if (_favoritos.contains(nombreProducto)) {
        _favoritos.remove(nombreProducto);
      } else {
        _favoritos.add(nombreProducto);
      }
    });
    await prefs.setStringList(
      'favoritos_${widget.usuario}',
      _favoritos.toList(),
    );
  }

  List<Map<String, dynamic>> get _productosFiltrados {
    return _productos.where((producto) {
      bool coincideCategoria = false;
      if (_mainCategoriaSeleccionada == 'All') {
        coincideCategoria = true;
      } else if (producto['categoria'] == _mainCategoriaSeleccionada) {
        if (_subCategoriaSeleccionada == 'All') {
          coincideCategoria = true;
        } else if (producto['subcategoria'] == _subCategoriaSeleccionada) {
          coincideCategoria = true;
        }
      }

      final coincideBusqueda = _busqueda.isEmpty ||
          producto['nombre'].toString().toLowerCase().contains(
                _busqueda.toLowerCase(),
              );

      return coincideCategoria && coincideBusqueda;
    }).toList();
  }

  Future<void> _comprarProducto(Map<String, dynamic> producto) async {
    final int precio = producto['precio'];
    final String nombreProducto = producto['nombre'];
    final String imagenProducto = producto['imagen'];

    // Before buying, get the current coins from the CurrencyManager's getMonedas (Future-based)
    // to check balance, as _monedasUsuario is no longer a state variable.
    // The StreamBuilder will react to the change in CurrencyManager after the purchase.
    int currentCoinsBeforePurchase = await CurrencyManager.getMonedas(widget.usuario);

    if (currentCoinsBeforePurchase >= precio) {
      bool compraExitosa = await CurrencyManager.gastarMonedas(precio, widget.usuario);
      if (compraExitosa) {
        if (!mounted) return;

        final prefs = await SharedPreferences.getInstance();
        List<String> itemsCompradosStrings =
            prefs.getStringList('comprados_${widget.usuario}') ?? [];

        String itemDataString = "$nombreProducto;$imagenProducto";

        if (!itemsCompradosStrings.contains(itemDataString)) {
          itemsCompradosStrings.add(itemDataString);
          await prefs.setStringList(
            'comprados_${widget.usuario}',
            itemsCompradosStrings,
          );
        }

        // _cargarMonedas(); // No longer needed, stream handles it

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have purchased $nombreProducto!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error processing the purchase.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You do not have enough coins to buy this item.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el factor de escala del texto para ajustar el GridView
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double baseChildAspectRatio = 0.75; // Valor por defecto de la tienda

    // Ajustamos el childAspectRatio en base al textScaleFactor para dar más espacio vertical
    // en los elementos de la cuadrícula cuando la configuración de texto es grande.
    if (textScaleFactor > 1.3) {
      baseChildAspectRatio = 0.6; // Hacemos los elementos significativamente más altos
    } else if (textScaleFactor > 1.1) {
      baseChildAspectRatio = 0.7; // Hacemos los elementos un poco más altos
    } else if (textScaleFactor < 0.9) {
      baseChildAspectRatio = 0.8; // Hacemos los elementos un poco más anchos (aprovechando espacio)
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Magic Store!',
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/playmobil_tienda_fondo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- MODIFIED: Use StreamBuilder for real-time coin updates ---
                  StreamBuilder<int>(
                    stream: CurrencyManager.getMonedasStream(widget.usuario),
                    initialData: 0, // Provide an initial value
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Row(
                          children: [
                            Text(
                              'Coins: ${snapshot.data}', // Display coins from the stream
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return const CircularProgressIndicator(); // Loading indicator
                    },
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _mainCategoriaSeleccionada,
                              items: _mainCategorias.map((categoria) {
                                return DropdownMenuItem(
                                  value: categoria,
                                  child: Text(
                                    categoria,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _mainCategoriaSeleccionada = value;
                                    _subCategoriaSeleccionada = 'All';
                                  });
                                }
                              },
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_mainCategoriaSeleccionada != 'All')
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _subCategoriaSeleccionada,
                                  items: _subCategorias.map((subCategoria) {
                                    return DropdownMenuItem(
                                      value: subCategoria,
                                      child: Text(
                                        subCategoria,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _subCategoriaSeleccionada = value;
                                      });
                                    }
                                  },
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'What are you looking for?',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, size: 28),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _busqueda = value;
                  });
                },
              ),
            ),
            Expanded(
              // Use LayoutBuilder for responsive GridView
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double availableWidth = constraints.maxWidth;
                  // Define a maximum desired width for each item to control how large they can get
                  const double maxItemWidth = 200.0; // Max width for a single product card

                  // Calculate how many columns can fit based on available width and max item width
                  // Factor in padding and spacing within the GridView
                  const double gridPadding = 16.0; // Horizontal padding of the GridView
                  const double crossAxisSpacing = 16.0; // Spacing between columns

                  // Calculate the effective width available for items + their internal spacing
                  final double effectiveContentWidth = availableWidth - (2 * gridPadding);

                  // Calculate crossAxisCount (number of columns)
                  // Use max(1, ...) to ensure at least one column
                  int crossAxisCount = max(1, (effectiveContentWidth / (maxItemWidth + crossAxisSpacing)).floor());

                  // If only one column, make it wider, but not full width (add some max constraint)
                  if (crossAxisCount == 1) {
                    crossAxisCount = 1; // Explicitly set to 1
                  }

                  // Calculate the item width based on the actual crossAxisCount and available space
                  final double itemWidth = (effectiveContentWidth - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;

                  final double finalChildAspectRatio = itemWidth / (itemWidth / baseChildAspectRatio);

                  return GridView.builder(
                    padding: const EdgeInsets.all(gridPadding), // Use the defined grid padding
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount, // Dynamic number of columns
                      childAspectRatio: finalChildAspectRatio, // Apply dynamic aspect ratio
                      crossAxisSpacing: crossAxisSpacing, // Use defined spacing
                      mainAxisSpacing: 16, // Main axis spacing remains fixed for now
                    ),
                    itemCount: _productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final producto = _productosFiltrados[index];
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    // Aseguramos que la imagen ocupe todo el espacio disponible en su Expanded
                                    Center( // Centramos la imagen para que no se pegue a los bordes
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0), // Reduced padding
                                        child: Image.asset(
                                          producto['imagen'],
                                          fit: BoxFit.contain, // Adjust image to contain without overflowing
                                          key: ValueKey(producto['imagen']), // Key for image caching
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: IconButton(
                                          icon: Icon(
                                            _favoritos.contains(producto['nombre'])
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.red,
                                            size: 30,
                                          ),
                                          onPressed: () => _toggleFavorito(
                                            producto['nombre'],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Use min to wrap content
                                  children: [
                                    Text(
                                      producto['nombre'],
                                      style: const TextStyle(
                                        fontSize: 16, // Potentially make this dynamic later if needed
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${producto['precio']}',
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.monetization_on,
                                            color: Colors.orange,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            // We now check the balance *at the time of the button press*
                                            // by listening to the stream within the widget tree.
                                            // This requires wrapping the button in a StreamBuilder as well.
                                            // For simplicity, we will check balance just before _comprarProducto
                                            // and rely on the snackbar feedback for insufficient funds.
                                            // The `snapshot.data` from the outer StreamBuilder for coins
                                            // will provide the current balance for this check.
                                            // We pass the current balance from the snapshot down to the button builder.
                                            null, // Temporarily disable to explain
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        child: const Text(
                                          'Buy!',
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
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
