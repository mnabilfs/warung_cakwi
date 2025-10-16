import 'package:flutter/material.dart';
import '../../utils/price_formatter.dart';

class CartTotalSection extends StatelessWidget {
  final int itemCount;
  final int totalPrice;
  final VoidCallback onCheckout;

  const CartTotalSection({
    super.key,
    required this.itemCount,
    required this.totalPrice,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, -3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Item:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
              Text('$itemCount item', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Harga:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              Text(
                'Rp ${PriceFormatter.format(totalPrice)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4A017)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: itemCount == 0 ? null : onCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A017),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}