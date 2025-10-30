import 'package:flutter/material.dart';
import '../../../../models/menu_item.dart';
import '../../../../utils/price_formatter.dart';

class CartItemView extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onRemove;

  const CartItemView({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF3D3D3D),
          child: Icon(item.icon, color: const Color(0xFFD4A017)),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Rp ${PriceFormatter.format(item.price)}',
          style: const TextStyle(
            color: Color(0xFFD4A017),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }
}