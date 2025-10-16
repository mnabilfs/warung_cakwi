// lib/pages/landing_page.dart
import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';
import '../models/menu_item.dart';
import 'cart_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // NON-STATIC: state nyata milik halaman ini
  final List<MenuItem> _cartItems = [];

  void _addToCart(MenuItem item) {
    setState(() => _cartItems.add(item));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Navigasi ke halaman cart.
  /// Await agar ketika kembali, landing page bisa memastikan tampilannya telah
  /// diperbarui (mis. badge).
  Future<void> _navigateToCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          // KIRIMKAN REFERENSI list, bukan salinan.
          cartItems: _cartItems,
          onRemoveItem: (index) {
            // callback dari CartPage: hapus di sini supaya sumber kebenaran (single source of truth)
            setState(() {
              if (index >= 0 && index < _cartItems.length) {
                _cartItems.removeAt(index);
              }
            });
          },
        ),
      ),
    );

    // Pastikan rebuild setelah kembali dari CartPage (badge, dsb.)
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Warung Cakwi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[700],
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // IconButton tetap bisa menerima tap sepenuhnya
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: _navigateToCart,
                  tooltip: 'Lihat Keranjang',
                ),

                // Badge: jangan menyerap pointer agar IconButton tidak terganggu
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 8,
                    child: IgnorePointer(
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
                          '${_cartItems.length}',
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
              ],
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const SizedBox(height: 20),
            _buildMenuSection('Bakso', [
              MenuItem(
                'Bakso Urat',
                'Bakso dengan urat sapi pilihan',
                15000,
                Icons.soup_kitchen,
              ),
              MenuItem(
                'Bakso Campur',
                'Bakso campur komplit',
                18000,
                Icons.ramen_dining,
              ),
              MenuItem(
                'Bakso Telur',
                'Bakso dengan telur puyuh',
                16000,
                Icons.egg,
              ),
              MenuItem(
                'Bakso Jumbo',
                'Bakso ukuran jumbo',
                20000,
                Icons.dining,
              ),
            ], _addToCart),
            _buildMenuSection('Mie Ayam', [
              MenuItem(
                'Mie Ayam Original',
                'Mie ayam dengan topping ayam',
                12000,
                Icons.ramen_dining,
              ),
              MenuItem(
                'Mie Ayam Bakso',
                'Mie ayam dengan bakso',
                15000,
                Icons.restaurant,
              ),
              MenuItem(
                'Mie Ayam Pangsit',
                'Mie ayam dengan pangsit goreng',
                14000,
                Icons.fastfood,
              ),
              MenuItem(
                'Mie Ayam Komplit',
                'Mie ayam komplit semua topping',
                18000,
                Icons.dinner_dining,
              ),
            ], _addToCart),
            _buildMenuSection('Minuman', [
              MenuItem(
                'Es Teh Manis',
                'Teh manis dingin segar',
                3000,
                Icons.local_drink,
              ),
              MenuItem(
                'Es Jeruk',
                'Jeruk peras segar',
                5000,
                Icons.emoji_food_beverage,
              ),
              MenuItem('Teh Hangat', 'Teh hangat nikmat', 2000, Icons.coffee),
              MenuItem(
                'Air Mineral',
                'Air mineral botol',
                3000,
                Icons.water_drop,
              ),
            ], _addToCart),
            _buildMenuSection('Menu Lainnya', [
              MenuItem(
                'Siomay',
                'Siomay dengan saus kacang',
                10000,
                Icons.set_meal,
              ),
              MenuItem(
                'Batagor',
                'Batagor goreng renyah',
                12000,
                Icons.restaurant_menu,
              ),
              MenuItem('Kerupuk', 'Kerupuk udang renyah', 2000, Icons.cookie),
              MenuItem(
                'Sambal Extra',
                'Sambal pedas mantap',
                1000,
                Icons.local_fire_department,
              ),
            ], _addToCart),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // Helper widgets (banner, drawer, menu section)
  // -------------------------
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[700]!, Colors.orange[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.restaurant, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Warung Cakwi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Makanan Enak, Harga Terjangkau',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.orange),
            title: const Text('Beranda'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.red),
            title: const Text('Lokasi Toko'),
            subtitle: const Text('Lihat lokasi warung kami'),
            onTap: () {
              Navigator.pop(context);
              _showLocationDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text('Hubungi Kami'),
            subtitle: const Text('0812-3456-7890'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Telepon: 0812-3456-7890')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time, color: Colors.blue),
            title: const Text('Jam Operasional'),
            subtitle: const Text('Setiap Hari: 08.00 - 21.00'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.location_on, color: Colors.red),
            SizedBox(width: 10),
            Text('Lokasi Warung Cakwi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Jl. Raya Gubeng No. 123\nSurabaya, Jawa Timur\n60281',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15),
            Text(
              'Dekat dengan:\n• Kampus ITS\n• Pasar Atom\n• Stasiun Gubeng',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka Google Maps...')),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.map),
            label: const Text('Buka Maps'),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[700]!, Colors.orange[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=800',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.3),
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Nikmati Kelezatan Warung Cakwi',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '⭐ 4.8/5.0 Rating',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // Responsive menu section using LayoutBuilder (sesuai Modul 2)
  // -------------------------
  Widget _buildMenuSection(
    String title,
    List<MenuItem> items,
    Function(MenuItem) onAddToCart,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;
        final int crossAxisCount = isWide ? 2 : 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.orange[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isWide ? 2.3 : 2.7,
              ),
              itemBuilder: (context, index) {
                final menuItem = items[index];
                return MenuCard(
                  item: menuItem,
                  onTap: () {
                    // buka detail pop-up responsif
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 600),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Scaffold(
                              appBar: AppBar(
                                title: Text(menuItem.name),
                                backgroundColor: Colors.orange[700],
                              ),
                              body: Center(
                                child: Hero(
                                  tag: menuItem.name,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final screenWidth = MediaQuery.of(
                                          context,
                                        ).size.width;
                                        final screenHeight = MediaQuery.of(
                                          context,
                                        ).size.height;
                                        final isLandscape =
                                            MediaQuery.of(
                                              context,
                                            ).orientation ==
                                            Orientation.landscape;

                                        final double popupWidth = isLandscape
                                            ? screenWidth * 0.5
                                            : screenWidth * 0.8;
                                        final double popupHeight = isLandscape
                                            ? screenHeight * 0.7
                                            : screenHeight * 0.8;

                                        return Container(
                                          width: popupWidth,
                                          constraints: BoxConstraints(
                                            maxHeight: popupHeight,
                                          ),
                                          padding: const EdgeInsets.all(20),
                                          margin: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  menuItem.icon,
                                                  size: 100,
                                                  color: Colors.orange[700],
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  menuItem.name,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  menuItem.description,
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  'Harga: Rp ${_formatPrice(menuItem.price)}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.orange[700],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                ElevatedButton.icon(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.orange[700],
                                                      ),
                                                  onPressed: () {
                                                    onAddToCart(menuItem);
                                                    Navigator.pop(context);
                                                  },
                                                  icon: const Icon(
                                                    Icons.add_shopping_cart,
                                                  ),
                                                  label: const Text(
                                                    'Tambah ke Keranjang',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}