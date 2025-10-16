import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../utils/price_formatter.dart';

class MenuDetailDialog extends StatelessWidget {
  final MenuItem menuItem;
  final Function(MenuItem) onAddToCart;

  const MenuDetailDialog({
    super.key,
    required this.menuItem,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Background hitam
      appBar: AppBar(
        title: Text(
          menuItem.name,
          style: const TextStyle(color: Color(0xFFD4A017)),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        iconTheme: const IconThemeData(color: Color(0xFFD4A017)),
      ),
      body: Center(
        child: Hero(
          tag: menuItem.name,
          child: Material(
            color: Colors.transparent,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                final isLandscape = MediaQuery.of(context).orientation ==
                    Orientation.landscape;

                final double popupWidth =
                    isLandscape ? screenWidth * 0.5 : screenWidth * 0.8;
                final double popupHeight =
                    isLandscape ? screenHeight * 0.7 : screenHeight * 0.8;

                return Container(
                  width: popupWidth,
                  constraints: BoxConstraints(maxHeight: popupHeight),
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D), // Abu gelap
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4A017).withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4A017).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon dengan background
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D3D3D),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            menuItem.icon,
                            size: 80,
                            color: const Color(0xFFD4A017),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          menuItem.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4A017),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          menuItem.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Divider
                        Container(
                          height: 1,
                          width: double.infinity,
                          color: const Color(0xFFD4A017).withOpacity(0.3),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Harga: Rp ${PriceFormatter.format(menuItem.price)}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFFD4A017),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A017),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            onAddToCart(menuItem);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text(
                            'Tambah ke Keranjang',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
