import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../utils/price_formatter.dart';

/// MenuCard dengan ANIMASI EKSPLISIT
class MenuCard extends StatefulWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const MenuCard({super.key, required this.item, this.onTap});

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderOpacityAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _borderOpacityAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 5.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _backgroundColorAnimation = ColorTween(
      begin: const Color(0xFF2D2D2D),
      end: const Color(0xFF3D3D3D),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _backgroundColorAnimation.value,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFFD4A017).withOpacity(_borderOpacityAnimation.value),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFD4A017).withOpacity(_borderOpacityAnimation.value * 0.5),
                    blurRadius: _glowAnimation.value,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
                leading: Hero(
                  tag: widget.item.name,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF3D3D3D),
                    child: Icon(widget.item.icon, color: const Color(0xFFD4A017), size: 30),
                  ),
                ),
                title: Text(
                  widget.item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                subtitle: Text(
                  widget.item.description,
                  style: const TextStyle(fontSize: 13, color: Colors.white60),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${PriceFormatter.format(widget.item.price)}',
                      style: const TextStyle(color: Color(0xFFD4A017), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    const Icon(Icons.add_shopping_cart, color: Color(0xFFD4A017), size: 20),
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