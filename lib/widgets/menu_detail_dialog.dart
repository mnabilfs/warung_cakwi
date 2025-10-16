import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../utils/price_formatter.dart';

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
      appBar: AppBar(
        title: Text(menuItem.name),
        backgroundColor: Colors.orange[700],
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
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          menuItem.icon,
                          size: 100,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          menuItem.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          menuItem.description,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Harga: Rp ${PriceFormatter.format(menuItem.price)}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                          ),
                          onPressed: () {
                            onAddToCart(menuItem);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Tambah ke Keranjang'),
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