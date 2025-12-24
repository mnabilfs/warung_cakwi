import 'package:flutter/material.dart';
import '../../../../utils/price_formatter.dart';

<<<<<<< HEAD
// 🔍 MARKER: ERROR_PREVENTION_CHECKOUT_BUTTON
=======
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
class CartTotalView extends StatelessWidget {
  final int itemCount;
  final int totalPrice;
  final VoidCallback onCheckout;
<<<<<<< HEAD
  final bool isProcessing; // ✅ TAMBAHKAN parameter ini
=======
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0

  const CartTotalView({
    super.key,
    required this.itemCount,
    required this.totalPrice,
    required this.onCheckout,
<<<<<<< HEAD
    this.isProcessing = false, // ✅ Default false
  });

  bool get canCheckout => itemCount > 0 && !isProcessing; // ✅ Cek isProcessing
=======
  });

  bool get canCheckout => itemCount > 0;
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0

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
              const Text(
                'Total Item:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                '$itemCount item',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Harga:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                'Rp ${PriceFormatter.format(totalPrice)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4A017),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
<<<<<<< HEAD
          // ✅ ERROR PREVENTION: Checkout button dengan loading state
=======
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
          ElevatedButton(
            onPressed: canCheckout ? onCheckout : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A017),
              foregroundColor: Colors.black,
<<<<<<< HEAD
              disabledBackgroundColor: Colors.grey,
=======
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
<<<<<<< HEAD
            child: isProcessing
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Memproses...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Checkout',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
=======
            child: const Text(
              'Checkout',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
