import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/menucard_controller.dart';
import '../../../../utils/price_formatter.dart';

class MenuCardView extends StatefulWidget {
  final VoidCallback? onTap;

  const MenuCardView({super.key, this.onTap});

  @override
  State<MenuCardView> createState() => _MenuCardViewState();
}

class _MenuCardViewState extends State<MenuCardView> {
  late MenuCardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MenuCardController>();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => controller.onTapDown(),
      onTapUp: (_) {
        controller.onTapUp();
        widget.onTap?.call();
      },
      onTapCancel: () => controller.onTapUp(),
      child: AnimatedBuilder(
        animation: controller.animController,
        builder: (context, child) {
          return Transform.scale(
            scale: controller.scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: controller.backgroundColorAnimation.value,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4A017)
                      .withOpacity(controller.borderOpacityAnimation.value),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4A017)
                        .withOpacity(controller.borderOpacityAnimation.value * 0.5),
                    blurRadius: controller.glowAnimation.value,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
                leading: Hero(
                  tag: controller.item.name,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF3D3D3D),
                    child: Icon(
                      controller.item.icon,
                      color: const Color(0xFFD4A017),
                      size: 30,
                    ),
                  ),
                ),
                title: Text(
                  controller.item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  controller.item.description,
                  style: const TextStyle(fontSize: 13, color: Colors.white60),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${PriceFormatter.format(controller.item.price)}',
                      style: const TextStyle(
                        color: Color(0xFFD4A017),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Icon(
                      Icons.add_shopping_cart,
                      color: Color(0xFFD4A017),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}