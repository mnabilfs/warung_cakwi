import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Wajib untuk Get.find dan Obx
import '../data/models/menu_item.dart';
import '../widgets/cart/mengatur_tampilan_saat_keranjang_kosong/view/cartempty_view.dart';
import '../widgets/cart/mengatur_tampilan_item_dalam_keranjang/view/cartitem_view.dart';
import '../widgets/cart/mengatur_bagian_bawah_halaman/view/carttotal_view.dart';
import '../utils/price_formatter.dart';
import '../data/controllers/menu_controller.dart' as my; // Alias MenuController

class CartPage extends StatefulWidget {

  // Constructor kini kosong karena data diambil dari Controller
  const CartPage({
    super.key,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Ambil instance controller (Hanya sekali saat State dibuat)
  final my.MenuController controller = Get.find<my.MenuController>();
  
  // 🔴 GETTER: Mengambil list Observable dari controller
  // Karena ini adalah getter, kita tidak memerlukan Obx di sini,
  // tetapi Obx harus digunakan di dalam build()
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
      // 🔴 Gunakan Obx untuk mendengarkan perubahan pada cartItems
      body: Obx(() {
        // PENTING: Menggunakan cartItems dari getter lokal (yang terikat ke controller)
        if (cartItems.isEmpty) {
          return const CartEmptyView();
        }
        
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartItems.length, // 🔴 Menggunakan cartItems lokal
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  
                  return CartItemView(
                    item: item,
                    onRemove: () => _removeItem(index), // Memanggil fungsi lokal
                  );
                },
              ),
            ),
            // Total View tetap di dalam Obx agar totalPrice diperbarui
            CartTotalView(
              itemCount: cartItems.length, // 🔴 Menggunakan cartItems lokal
              totalPrice: totalPrice,
              onCheckout: _showCheckoutDialog,
            ),
          ],
        );
      }),
    );
  }

  void _removeItem(int index) {
    // 1. Dapatkan item sebelum dihapus untuk SnackBar
    final item = cartItems[index];
    
    // 2. 🔴 Panggil fungsi REMOVE dari Controller (yang sudah terintegrasi dengan Hive)
    controller.removeFromCart(index);
    
    // 3. Tampilkan SnackBar (Kode SnackBar tetap sama, hanya memanggil controller)
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
    // Tidak perlu setState({}) karena perubahan di controller memicu Obx
  }

  void _showCheckoutDialog() {
    // Logika Checkout tetap sama
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(color: Color(0xFFD4A017)),
        ),
        content: Text(
          'Total pesanan Anda Rp ${PriceFormatter.format(totalPrice)}.\nLanjutkan ke pembayaran?',
          style: const TextStyle(color: Colors.white),
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
              backgroundColor: const Color(0xFFD4A017),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage();
              // ⚠️ TO DO: Di sini nanti ditambahkan logika Supabase INSERT ORDER
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage() {
    // Logika SnackBar Sukses tetap sama
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Pesanan berhasil!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
  }
}