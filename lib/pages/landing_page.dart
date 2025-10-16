import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../widgets/header_banner.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/menu_section.dart';
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
      SnackBar(content: Text('${item.name} ditambahkan ke keranjang')),
    );
  }

  Future<void> _navigateToCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cartItems: _cartItems,
          onRemoveItem: (i) => setState(() => _cartItems.removeAt(i)),
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warung Cakwi'),
        backgroundColor: Colors.orange[700],
        actions: [
          IconButton(
            icon: Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartItems.isNotEmpty)
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${_cartItems.length}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            onPressed: _navigateToCart,
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderBanner(),
            const SizedBox(height: 20),
            MenuSection(
              title: 'Bakso',
              items: [
                MenuItem('Bakso Urat', 'Bakso urat sapi', 15000, Icons.soup_kitchen),
                MenuItem('Bakso Campur', 'Bakso campur komplit', 18000, Icons.ramen_dining),
              ],
              onAddToCart: _addToCart,
            ),
            MenuSection(
              title: 'Minuman',
              items: [
                MenuItem('Es Teh Manis', 'Teh manis segar', 3000, Icons.local_drink),
                MenuItem('Es Jeruk', 'Jeruk peras segar', 5000, Icons.emoji_food_beverage),
              ],
              onAddToCart: _addToCart,
            ),
          ],
        ),
      ),
    );
  }
}
