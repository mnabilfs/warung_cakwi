import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../utils/price_formatter.dart';

class MenuDetailDialog extends StatefulWidget {
  final MenuItem menuItem;
  final Function(MenuItem) onAddToCart;

  const MenuDetailDialog({
    super.key,
    required this.menuItem,
    required this.onAddToCart,
  });

  @override
  State<MenuDetailDialog> createState() => _MenuDetailDialogState();
}

class _MenuDetailDialogState extends State<MenuDetailDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconRotateAnimation;

  // 🔹 State untuk animasi implisit tombol
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _iconRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 6.28,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(
          widget.menuItem.name,
          style: const TextStyle(color: Color(0xFFD4A017)),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        iconTheme: const IconThemeData(color: Color(0xFFD4A017)),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Hero(
                  tag: widget.menuItem.name,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4A017).withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4A017).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.rotate(
                              angle: _iconRotateAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF3D3D3D),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.menuItem.icon,
                                  size: 80,
                                  color: const Color(0xFFD4A017),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              widget.menuItem.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4A017),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.menuItem.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: const Color(0xFFD4A017).withOpacity(0.3),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Harga: Rp ${PriceFormatter.format(widget.menuItem.price)}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFFD4A017),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 25),

                            // 🔸 Tombol dengan ANIMASI IMPLISIT
                            AnimatedScale(
                              duration: const Duration(milliseconds: 150),
                              scale: _isButtonPressed ? 0.95 : 1.0,
                              curve: Curves.easeInOut,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4A017),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isButtonPressed = true;
                                  });
                                  Future.delayed(
                                    const Duration(milliseconds: 150),
                                    () {
                                      setState(() {
                                        _isButtonPressed = false;
                                      });
                                      widget.onAddToCart(widget.menuItem);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text(
                                  'Tambah ke Keranjang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
