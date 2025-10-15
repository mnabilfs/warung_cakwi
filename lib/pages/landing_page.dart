import 'package:flutter/material.dart';
import 'bakso_page.dart';
import 'mie_ayam_page.dart';
import 'menu_lain_page.dart';
import 'minuman_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.ramen_dining, size: 100, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                "Warung Ojolali Cakwi",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 40),
              _menuButton(
                context,
                label: "Menu Bakso",
                color: Colors.orange,
                page: const BaksoPage(),
              ),
              const SizedBox(height: 12),
              _menuButton(
                context,
                label: "Menu Mie Ayam",
                color: Colors.green,
                page: const MieAyamPage(),
              ),
              const SizedBox(height: 12),
              _menuButton(
                context,
                label: "Menu Lain",
                color: Colors.blueAccent,
                page: const MenuLainPage(),
              ),
              const SizedBox(height: 12),
              _menuButton(
                context,
                label: "Minuman",
                color: Colors.teal,
                page: const MinumanPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context,
      {required String label, required Color color, required Widget page}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
