import 'package:flutter/material.dart';
import '../models/menu_item.dart';

/// Halaman keranjang belanja
class CartPage extends StatefulWidget {
  final List<MenuItem> cartItems;
  final Function(int) onRemoveItem;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onRemoveItem,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int get totalPrice =>
      widget.cartItems.fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: Colors.orange[700],
      ),
      body: widget.cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, i) =>
                        _buildCartItem(widget.cartItems[i], i),
                  ),
                ),
                _buildTotalSection(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          'Keranjang Kosong',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tambahkan menu favorit Anda!',
          style: TextStyle(color: Colors.grey[500]),
        ),
      ],
    ),
  );

  Widget _buildCartItem(MenuItem item, int index) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.orange[100],
        child: Icon(item.icon, color: Colors.orange[700]),
      ),
      title: Text(
        item.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        'Rp ${_formatPrice(item.price)}',
        style: TextStyle(
          color: Colors.orange[700],
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          widget.onRemoveItem(index);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.name} dihapus dari keranjang')),
          );
          setState(() {});
        },
      ),
    ),
  );

  Widget _buildTotalSection() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
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
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            Text(
              '${widget.cartItems.length} item',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Harga:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Rp ${_formatPrice(totalPrice)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: widget.cartItems.isEmpty ? null : _checkoutDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Checkout',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ],
    ),
  );

  void _checkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pesanan'),
        content: Text(
          'Total pesanan Anda Rp ${_formatPrice(totalPrice)}.\nLanjutkan ke pembayaran?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pesanan berhasil!')),
              );
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
}