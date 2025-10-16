import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../widgets/cart/cart_empty_state.dart';
import '../widgets/cart/cart_item_card.dart';
import '../widgets/cart/cart_total_section.dart';

/// Halaman keranjang belanja - FILE UTAMA
class CartPage extends StatefulWidget {
  final List<MenuItem> cartItems;
  final Function(int) onRemoveItem;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onRemoveItem,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int get totalPrice =>
      widget.cartItems.fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(color: Color(0xFFD4A017)),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        iconTheme: const IconThemeData(color: Color(0xFFD4A017)),
      ),
      body: widget.cartItems.isEmpty
          ? const CartEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) => CartItemCard(
                      item: widget.cartItems[index],
                      onRemove: () => _removeItem(index),
                    ),
                  ),
                ),
                CartTotalSection(
                  itemCount: widget.cartItems.length,
                  totalPrice: totalPrice,
                  onCheckout: _showCheckoutDialog,
                ),
              ],
            ),
    );
  }

  void _removeItem(int index) {
    final item = widget.cartItems[index];
    widget.onRemoveItem(index);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.name} dihapus dari keranjang',
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
          side: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
    setState(() {});
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(color: Color(0xFFD4A017)),
        ),
        content: Text(
          'Total pesanan Anda Rp ${_formatPrice(totalPrice)}.\nLanjutkan ke pembayaran?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A017),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage();
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Pesanan berhasil!',
          style: TextStyle(
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

  String _formatPrice(int price) => price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
}