import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/banner.dart';
import 'app_drawer.dart';
import '../widgets/cart/cart_button.dart';
import '../widgets/menu/menu_section.dart';
import '../controllers/menu_controller.dart' as my;
import 'cart_page.dart';

class LandingPage extends StatelessWidget {
  LandingPage({super.key});

final my.MenuController controller = Get.put(my.MenuController());

  Future<void> _navigateToCart(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CartPage(
          cartItems: controller.cartItems,
          onRemoveItem: (index) => controller.removeFromCart(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Bakso Ojolali Cakwi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4A017),
          ),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        actions: [
          Obx(() => CartButton(
                itemCount: controller.cartItems.length,
                onPressed: () => _navigateToCart(context),
              )),
        ],
      ),
      drawer: const AppDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text('Gagal memuat data: ${controller.errorMessage}'));
        } else if (controller.menuItems.isEmpty) {
          return const Center(child: Text('Tidak ada data.'));
        }

        final items = controller.menuItems;
        return SingleChildScrollView(
          child: Column(
            children: [
              const AppBanner(),
              MenuSection(
                title: 'Menu',
                items: items,
                onAddToCart: controller.addToCart,
              ),
            ],
          ),
        );
      }),
    );
  }
}
