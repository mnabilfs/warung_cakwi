import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/menudetail_controller.dart';
import '../../../../models/menu_item.dart';  
import '../../../../utils/price_formatter.dart';

class MenuDetailView extends GetView<MenuDetailController> {
  final Function(MenuItem) onAddToCart;

  const MenuDetailView({super.key, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(
          controller.menuItem.name,
          style: const TextStyle(color: Color(0xFFD4A017)),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        iconTheme: const IconThemeData(color: Color(0xFFD4A017)),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: controller.animController,
          builder: (context, child) {
            return Opacity(
              opacity: controller.fadeAnimation.value,
              child: Transform.scale(
                scale: controller.scaleAnimation.value,
                child: Hero(
                  tag: controller.menuItem.name,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
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
                            Transform.rotate(
                              angle: controller.iconRotateAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF3D3D3D),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  controller.menuItem.icon,
                                  size: 80,
                                  color: const Color(0xFFD4A017),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              controller.menuItem.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4A017),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              controller.menuItem.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: const Color(0xFFD4A017).withOpacity(0.3),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Harga: Rp ${PriceFormatter.format(controller.menuItem.price)}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFFD4A017),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Obx(() => AnimatedScale(
                                  duration: const Duration(milliseconds: 150),
                                  scale: controller.isButtonPressed.value ? 0.95 : 1.0,
                                  curve: Curves.easeInOut,
                                  child: ElevatedButton.icon(
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
                                      controller.pressButton();
                                      Future.delayed(
                                        const Duration(milliseconds: 150),
                                        () {
                                          controller.releaseButton();
                                          onAddToCart(controller.menuItem);
                                          Navigator.pop(context);
                                        },
                                      );
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
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}