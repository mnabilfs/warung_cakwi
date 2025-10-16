import 'package:flutter/material.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D2D2D), // Abu gelap
            const Color(0xFF1A1A1A), // Hitam
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Efek daun hijau di background
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.eco,
              size: 150,
              color: const Color(0xFF8FBC8F).withOpacity(0.1),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Icon(
              Icons.eco,
              size: 120,
              color: const Color(0xFF8FBC8F).withOpacity(0.1),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: Color(0xFFD4A017), // Kuning emas
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bakso Ojolali Cakwi',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A017), // Kuning emas
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Daftar Menu Terlengkap',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⭐ Menerima Pesanan',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}