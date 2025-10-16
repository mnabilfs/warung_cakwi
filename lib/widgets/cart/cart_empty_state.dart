import 'package:flutter/material.dart';

/// Widget untuk menampilkan state ketika keranjang kosong
class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'Keranjang Kosong',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tambahkan menu favorit Anda!',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}