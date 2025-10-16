import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import 'menu_card.dart';

class MenuSection extends StatelessWidget {
  final String title;
  final List<MenuItem> items;
  final Function(MenuItem) onAddToCart;

  const MenuSection({
    super.key,
    required this.title,
    required this.items,
    required this.onAddToCart,
  });

  String _formatPrice(int price) => price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;
        final int crossAxisCount = isWide ? 2 : 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.orange[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isWide ? 2.3 : 2.7,
              ),
              itemBuilder: (context, index) {
                final menuItem = items[index];
                return MenuCard(
                  item: menuItem,
                  onTap: () => onAddToCart(menuItem),
                );
              },
            ),
          ],
        );
      },
    );
  }
}