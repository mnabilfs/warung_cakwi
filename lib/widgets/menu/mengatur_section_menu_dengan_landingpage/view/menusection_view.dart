import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/menusection_controller.dart';
import '../../../../data/models/menu_item.dart'; 
import '../../mengatur_card_menu_di_landingpage/controller/menucard_controller.dart';
import '../../mengatur_card_menu_di_landingpage/view/menucard_view.dart';
import '../../mengatur_dialong_menu_saat_card_menu_diklik/controller/menudetail_controller.dart';
import '../../mengatur_dialong_menu_saat_card_menu_diklik/view/menudetail_view.dart';

class MenuSectionView extends GetView<MenuSectionController> {
  const MenuSectionView({super.key});

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
              color: const Color(0xFFD4A017),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            controller.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4A017),
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
      itemCount: controller.items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWide ? 2.3 : 2.7,
      ),
      itemBuilder: (context, index) {
        final menuItem = controller.items[index];
        
        // Put MenuCardController untuk setiap item
        Get.put(MenuCardController(item: menuItem), tag: menuItem.name);
        
        return MenuCardView(
          key: ValueKey(menuItem.name),
          onTap: () => _showMenuDetail(context, menuItem),
        );
      },
    );
  }

  void _showMenuDetail(BuildContext context, MenuItem menuItem) {
    // Put MenuDetailController
    Get.put(MenuDetailController(menuItem: menuItem), tag: '${menuItem.name}_detail');
    
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => MenuDetailView(
          key: ValueKey('${menuItem.name}_detail'),
          onAddToCart: controller.onAddToCart,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}