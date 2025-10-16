import 'package:flutter/material.dart';
import '../widgets/app_banner.dart';
import '../widgets/app_drawer.dart';
import '../widgets/cart_button.dart';
import '../widgets/menu_section.dart';
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
        content: Text('${item.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _navigateToCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cartItems: _cartItems,
          onRemoveItem: (index) {
            setState(() {
              if (index >= 0 && index < _cartItems.length) {
                _cartItems.removeAt(index);
              }
            });
          },
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Warung Cakwi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[700],
        elevation: 0,
        actions: [
          CartButton(
            itemCount: _cartItems.length,
            onPressed: _navigateToCart,
          ),
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

  // Data menu items
  final List<MenuItem> _baksoMenu = const [
    MenuItem('Bakso Urat', 'Bakso dengan urat sapi pilihan', 15000, Icons.soup_kitchen),
    MenuItem('Bakso Campur', 'Bakso campur komplit', 18000, Icons.ramen_dining),
    MenuItem('Bakso Telur', 'Bakso dengan telur puyuh', 16000, Icons.egg),
    MenuItem('Bakso Jumbo', 'Bakso ukuran jumbo', 20000, Icons.dining),
  ];

  final List<MenuItem> _mieAyamMenu = const [
    MenuItem('Mie Ayam Original', 'Mie ayam dengan topping ayam', 12000, Icons.ramen_dining),
    MenuItem('Mie Ayam Bakso', 'Mie ayam dengan bakso', 15000, Icons.restaurant),
    MenuItem('Mie Ayam Pangsit', 'Mie ayam dengan pangsit goreng', 14000, Icons.fastfood),
    MenuItem('Mie Ayam Komplit', 'Mie ayam komplit semua topping', 18000, Icons.dinner_dining),
  ];

  final List<MenuItem> _minumanMenu = const [
    MenuItem('Es Teh Manis', 'Teh manis dingin segar', 3000, Icons.local_drink),
    MenuItem('Es Jeruk', 'Jeruk peras segar', 5000, Icons.emoji_food_beverage),
    MenuItem('Teh Hangat', 'Teh hangat nikmat', 2000, Icons.coffee),
    MenuItem('Air Mineral', 'Air mineral botol', 3000, Icons.water_drop),
  ];

  final List<MenuItem> _menuLainnya = const [
    MenuItem('Siomay', 'Siomay dengan saus kacang', 10000, Icons.set_meal),
    MenuItem('Batagor', 'Batagor goreng renyah', 12000, Icons.restaurant_menu),
    MenuItem('Kerupuk', 'Kerupuk udang renyah', 2000, Icons.cookie),
    MenuItem('Sambal Extra', 'Sambal pedas mantap', 1000, Icons.local_fire_department),
  ];
}