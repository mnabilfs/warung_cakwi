import 'package:flutter/material.dart';
import '../models/menu_item.dart';

/// Widget kartu menu dengan efek animasi halus saat ditekan
class MenuCard extends StatefulWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const MenuCard({super.key, required this.item, this.onTap});

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.orange[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(_isPressed ? 0.4 : 0.2),
              blurRadius: _isPressed ? 10 : 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Hero(
            tag: widget.item.name,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.orange[100],
              child: Icon(
                widget.item.icon,
                color: Colors.orange[700],
                size: 30,
              ),
            ),
          ),
          title: Text(
            widget.item.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            widget.item.description,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${_formatPrice(widget.item.price)}',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              const Icon(
                Icons.add_shopping_cart,
                color: Colors.orange,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}