import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import '../data/models/menu_item.dart';
import '../widgets/cart/mengatur_tampilan_saat_keranjang_kosong/view/cartempty_view.dart';
import '../widgets/cart/mengatur_tampilan_item_dalam_keranjang/view/cartitem_view.dart';
import '../widgets/cart/mengatur_bagian_bawah_halaman/view/carttotal_view.dart';
import '../utils/price_formatter.dart';
import '../data/controllers/menu_controller.dart' as my;
import '../data/services/notification_handler.dart'; 

class CartPage extends StatefulWidget {

  
  const CartPage({
    super.key,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  
  final my.MenuController controller = Get.find<my.MenuController>();
  
  
  
  
  List<MenuItem> get cartItems => controller.cartItems; 

  int get totalPrice => cartItems.fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(color: Color(0xFFD4A017)),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        iconTheme: const IconThemeData(color: Color(0xFFD4A017)),
      ),
      
      body: Obx(() {
        
        if (cartItems.isEmpty) {
          return const CartEmptyView();
        }
        
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartItems.length, 
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  
                  return CartItemView(
                    item: item,
                    onRemove: () => _removeItem(index), 
                  );
                },
              ),
            ),
            
            CartTotalView(
              itemCount: cartItems.length, 
              totalPrice: totalPrice,
              onCheckout: _showCheckoutDialog,
            ),
          ],
        );
      }),
    );
  }

  void _removeItem(int index) {
    
    final item = cartItems[index];
    
    
    controller.removeFromCart(index);
    
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.name} dihapus dari keranjang',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
    
  }

  void _showCheckoutDialog() {
    String? selectedPaymentMethod;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text(
            'Pilih Metode Pembayaran',
            style: TextStyle(color: Color(0xFFD4A017)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total: Rp ${PriceFormatter.format(totalPrice)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Metode Pembayaran:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              // Bayar di Tempat - Active
              _buildPaymentMethodCard(
                title: 'Bayar di Tempat',
                subtitle: 'Bayar saat pesanan diantar',
                icon: Icons.payments_outlined,
                isSelected: selectedPaymentMethod == 'cod',
                isEnabled: true,
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = 'cod';
                  });
                },
              ),
              const SizedBox(height: 10),
              // QRIS - Coming Soon
              _buildPaymentMethodCard(
                title: 'QRIS',
                subtitle: 'Scan QR untuk pembayaran',
                icon: Icons.qr_code_2,
                isSelected: false,
                isEnabled: false,
                badge: 'Segera Hadir',
                onTap: null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedPaymentMethod != null 
                    ? const Color(0xFFD4A017) 
                    : Colors.grey,
                foregroundColor: Colors.black,
              ),
              onPressed: selectedPaymentMethod != null
                  ? () {
                      Navigator.pop(context);
                      _showSuccessMessage(selectedPaymentMethod!);
                    }
                  : null,
              child: const Text('Lanjutkan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isEnabled,
    String? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF3D3D3D) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFD4A017) 
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isEnabled 
                    ? const Color(0xFFD4A017).withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isEnabled ? const Color(0xFFD4A017) : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isEnabled ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isEnabled ? Colors.white60 : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFD4A017),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String paymentMethod) {
    String methodText = paymentMethod == 'cod' ? 'Bayar di Tempat' : 'QRIS';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pesanan berhasil! Metode: $methodText',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFD4A017), width: 1),
        ),
      ),
    );
    
    // Clear cart after successful order
    controller.clearCart();
    
    // Show notification
    final notificationHandler = NotificationHandler();
    notificationHandler.showNotification(
      title: 'Pesanan Berhasil! 🎉',
      body: 'Pesanan Anda sedang diproses. Metode pembayaran: $methodText',
    );
  }
}