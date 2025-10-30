import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/cartbutton_controller.dart';

class CartButtonView extends StatefulWidget {
  final int itemCount;
  final VoidCallback onPressed;

  const CartButtonView({
    super.key,
    required this.itemCount,
    required this.onPressed,
  });

  @override
  State<CartButtonView> createState() => _CartButtonViewState();
}

class _CartButtonViewState extends State<CartButtonView> {
  late CartButtonController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CartButtonController());
    controller.previousCount = widget.itemCount;
  }

  @override
  void didUpdateWidget(CartButtonView oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.updateItemCount(widget.itemCount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: widget.onPressed,
            tooltip: 'Lihat Keranjang',
          ),
          if (widget.itemCount > 0)
            Positioned(
              right: 6,
              top: 8,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: controller.animController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: controller.scaleAnimation.value,
                      child: Transform.rotate(
                        angle: controller.rotationAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '${widget.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}