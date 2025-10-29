import 'package:flutter/material.dart';
import '../widgets/banner.dart';
import 'app_drawer.dart';
import '../widgets/cart/cart_button.dart';
import '../widgets/menu/menu_section.dart';
import '../models/menu_item.dart';
import '../services/api_service.dart'; // 🧩 tambahkan ini
import 'cart_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final List<MenuItem> _cartItems = [];
  late Future<List<MenuItem>> _menuItemsFuture; // 🆕

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = ApiService.fetchMenuItems(); // fetch API saat init
  }

  void _addToCart(MenuItem item) {
    setState(() => _cartItems.add(item));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} ditambahkan ke keranjang'),
        backgroundColor: const Color(0xFF2D2D2D),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _navigateToCart() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CartPage(
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
        actions: [
          CartButton(itemCount: _cartItems.length, onPressed: _navigateToCart),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<MenuItem>>(
        future: _menuItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data.'));
          }

          final items = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                const AppBanner(),
                MenuSection(
                  title: 'Menu',
                  items: items,
                  onAddToCart: _addToCart,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
