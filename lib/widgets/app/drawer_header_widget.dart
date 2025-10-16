import 'package:flutter/material.dart';

/// Widget header untuk drawer navigasi
class DrawerHeaderWidget extends StatelessWidget {
  const DrawerHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D2D2D),
            const Color(0xFF1A1A1A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          Icon(Icons.restaurant, size: 50, color: Color(0xFFD4A017)),
          SizedBox(height: 10),
          Text(
            'Bakso Ojolali Cakwi',
            style: TextStyle(
              color: Color(0xFFD4A017),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Makanan Enak, Harga Terjangkau',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}