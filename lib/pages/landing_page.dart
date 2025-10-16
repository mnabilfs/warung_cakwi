import 'package:flutter/material.dart';
import '../widgets/banner.dart';
import 'app_drawer.dart';
import '../widgets/cart/cart_button.dart';
import '../widgets/menu/menu_section.dart';
import '../models/menu_item.dart';
import 'cart_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final List<MenuItem> _cartItems = [];

  void _addToCart(MenuItem item) {
    setState(() => _cartItems.add(item));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.name} ditambahkan ke keranjang',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFD4A017), width: 1),
        ),
      ),
    );
  }

  Future<void> _navigateToCart() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => CartPage(
          cartItems: _cartItems,
          onRemoveItem: (index) {
            setState(() {
              if (index >= 0 && index < _cartItems.length) {
                _cartItems.removeAt(index);
              }
            });
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 🔹 Gabungan Fade + Slide Animation
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          final offset = Tween<Offset>(
            begin: const Offset(0.2, 0.0), // mulai dari kanan
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: offset, child: child),
          );
        },
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Bakso Ojolali Cakwi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4A017),
          ),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        iconTheme: const IconThemeData(color: Color(0xFFD4A017)),
        elevation: 0,
        actions: [
          CartButton(itemCount: _cartItems.length, onPressed: _navigateToCart),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBanner(),
              const SizedBox(height: 20),
            MenuSection(
              title: 'Bakso',
              items: _baksoMenu,
              onAddToCart: _addToCart,
            ),
            MenuSection(
              title: 'Mie Ayam',
              items: _mieAyamMenu,
              onAddToCart: _addToCart,
            ),
            MenuSection(
              title: 'Minuman',
              items: _minumanMenu,
              onAddToCart: _addToCart,
            ),
            MenuSection(
              title: 'Menu Lainnya',
              items: _menuLainnya,
              onAddToCart: _addToCart,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  final List<MenuItem> _baksoMenu = const [
    MenuItem('Bakso Campur', 'Bakso campur komplit', 10000, Icons.soup_kitchen),
    MenuItem(
      'Bakso Kasar Besar',
      'Bakso kasar ukuran besar',
      5000,
      Icons.ramen_dining,
    ),
    MenuItem(
      'Bakso Kasar Sedang',
      'Bakso kasar ukuran sedang',
      3000,
      Icons.dining,
    ),
    MenuItem(
      'Bakso Halus Sedang',
      'Bakso halus ukuran sedang',
      3000,
      Icons.restaurant,
    ),
    MenuItem('Bakso Krikil', 'Bakso krikil', 1000, Icons.fastfood),
    MenuItem('DLL', 'Dan lain-lain', 1000, Icons.more_horiz),
  ];

  final List<MenuItem> _mieAyamMenu = const [
    MenuItem('Mie Ayam Biasa', 'Mie ayam original', 10000, Icons.ramen_dining),
    MenuItem(
      'Mie Ayam Bakso',
      'Mie ayam dengan bakso',
      15000,
      Icons.restaurant,
    ),
  ];

  final List<MenuItem> _minumanMenu = const [
    MenuItem('Es Teh', 'Teh manis dingin segar', 5000, Icons.local_drink),
    MenuItem('Es Jeruk', 'Jeruk peras segar', 5000, Icons.emoji_food_beverage),
    MenuItem('Es Sogem', 'Es sogem segar', 10000, Icons.water_drop),
    MenuItem('Kopi', 'Kopi nikmat', 5000, Icons.coffee),
    MenuItem('Teh Hangat', 'Teh hangat nikmat', 4000, Icons.local_cafe),
    MenuItem('Jeruk Hangat', 'Jeruk hangat', 4000, Icons.coffee_maker),
  ];

  final List<MenuItem> _menuLainnya = const [
    MenuItem('Cuanki', 'Cuanki enak', 10000, Icons.set_meal),
    MenuItem(
      'Siomay',
      'Siomay dengan saus kacang',
      10000,
      Icons.restaurant_menu,
    ),
    MenuItem('Batagor', 'Batagor goreng renyah', 10000, Icons.fastfood),
  ];
}
