import 'package:flutter/material.dart';

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

class _CartButtonViewState extends State<CartButtonView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.itemCount;

    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // ✅ FIX: Simple Tween instead of TweenSequence
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(CartButtonView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation only when count increases
    if (widget.itemCount > _previousCount && !_animController.isAnimating) {
      _animController.forward(from: 0.0).then((_) {
        if (mounted) {
          _animController.reverse();
        }
      });
    }
    _previousCount = widget.itemCount;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
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
              ),
            ),
        ],
      ),
    );
  }
}