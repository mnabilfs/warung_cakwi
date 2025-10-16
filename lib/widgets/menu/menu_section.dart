import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import 'menu_card.dart';
import 'menu_detail_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;
        final int crossAxisCount = isWide ? 2 : 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            _buildMenuGrid(context, crossAxisCount, isWide),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A017), // Kuning emas
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4A017), // Kuning emas
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, int crossAxisCount, bool isWide) {
    return GridView.builder(
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
          onTap: () => _showMenuDetail(context, menuItem),
        );
      },
    );
  }

  void _showMenuDetail(BuildContext context, MenuItem menuItem) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            MenuDetailDialog(
          menuItem: menuItem,
          onAddToCart: onAddToCart,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
