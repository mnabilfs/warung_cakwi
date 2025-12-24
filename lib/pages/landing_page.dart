import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/controllers/menu_controller.dart' as my; 
import '../data/controllers/auth_controller.dart';

import '../widgets/banner/view/banner_view.dart';
import '../widgets/cart/mengatur_tombol_keranjang/view/cartbutton_view.dart';
import 'app_drawer.dart';
import 'cart_page.dart';

import 'package:flutter/foundation.dart';

import 'admin_dashboard_page.dart';

import '../widgets/home/ai_recommendation_banner.dart';

class LandingPage extends StatefulWidget { // ✅ Ubah ke StatefulWidget
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver { // ✅ Tambahkan observer
  final my.MenuController controller = Get.put(my.MenuController());
  final AuthController authC = Get.find<AuthController>(); 

  @override
  void initState() {
    super.initState();
    // ✅ Register observer untuk detect app lifecycle
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // ✅ Unregister observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // ✅ Refresh saat app kembali ke foreground (resumed)
    if (state == AppLifecycleState.resumed) {
      controller.fetchMenuItems();
      if (kDebugMode) print('✅ App resumed - Menu refreshed');
    }
  }

  Future<void> _navigateToCart(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Bakso Ojolali Cakwi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4A017),
          ),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        iconTheme: const IconThemeData(color: Color(0xFFD4A017)), 
        actions: [
          Obx(() {
            if (authC.isAdmin) {
              return IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: Color(0xFFD4A017)),
                tooltip: "Admin Dashboard",
                onPressed: () async {
                  // ✅ Refresh menu saat kembali dari admin dashboard
                  await Get.to(() => AdminDashboardPage());
                  controller.fetchMenuItems();
                },
              );
            }
            return const SizedBox.shrink();
          }),
          
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD4A017)),
            tooltip: "Keluar Aplikasi",
            onPressed: () {
              Get.defaultDialog(
                title: "Logout",
                titleStyle: const TextStyle(color: Color(0xFFD4A017), fontWeight: FontWeight.bold),
                middleText: "Apakah Anda yakin ingin keluar?",
                middleTextStyle: const TextStyle(color: Colors.white),
                backgroundColor: const Color(0xFF2D2D2D),
                textConfirm: "Ya, Keluar",
                textCancel: "Batal",
                confirmTextColor: Colors.black,
                buttonColor: const Color(0xFFD4A017),
                cancelTextColor: const Color(0xFFD4A017),
                onConfirm: () {
                  Get.back(); 
                  authC.logout(); 
                },
              );
            },
          ),
          
          Obx(() => CartButtonView(
            itemCount: controller.cartItems.length,
            onPressed: () => _navigateToCart(context),
          )),
        ],
      ),
      drawer: const AppDrawer(),
      
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4A017)));
        } else if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text('Gagal memuat data: ${controller.errorMessage}', 
              style: const TextStyle(color: Colors.white)),
          );
        } else if (controller.menuItems.isEmpty) {
          return const Center(child: Text('Tidak ada data.', 
              style: TextStyle(color: Colors.white)));
        }

        final items = controller.menuItems;

        return SingleChildScrollView(
          child: Column(
            children: [
              const BannerView(),
              _buildMenuSection(items),
            ],
          ),
        );
      }),
    );
  }

  // ... rest of the code remains the same ...
  
Widget _buildMenuSection(List items) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final bool isWide = constraints.maxWidth > 600;
      final int crossAxisCount = isWide ? 2 : 1;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ TAMBAHAN BARU: AI Recommendation Banner
          const AIRecommendationBanner(),
          
          _buildSectionHeader(),
          _buildMenuGrid(context, items, crossAxisCount, isWide),
          const SizedBox(height: 20), 
        ],
      );
    },
  );
}

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A017),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Menu Pilihan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4A017),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, List items, int crossAxisCount, bool isWide) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWide ? 2.5 : 3.0, 
      ),
      itemBuilder: (context, index) {
        final menuItem = items[index];
        return _buildMenuCard(context, menuItem);
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, dynamic menuItem) {
    return GestureDetector(
      onTap: () => _showMenuDetail(context, menuItem),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Hero(
                tag: menuItem.name, 
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D3D3D),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.5)),
                  ),
                  child: ClipOval(
                    child: menuItem.imageUrl != null && menuItem.imageUrl!.isNotEmpty
                        ? Image.network(
                            menuItem.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: const Color(0xFFD4A017),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                menuItem.icon ?? Icons.fastfood,
                                color: const Color(0xFFD4A017),
                                size: 30,
                              );
                            },
                          )
                        : Icon(
                            menuItem.icon ?? Icons.fastfood,
                            color: const Color(0xFFD4A017),
                            size: 30,
                          ),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    menuItem.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menuItem.description,
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${_formatPrice(menuItem.price)}',
                    style: const TextStyle(
                      color: Color(0xFFD4A017),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: Color(0xFFD4A017),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  void _showMenuDetail(BuildContext context, dynamic menuItem) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4A017).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (menuItem.imageUrl != null && menuItem.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      menuItem.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFFD4A017),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3D3D3D),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Icon(
                            menuItem.icon ?? Icons.fastfood,
                            size: 80,
                            color: const Color(0xFFD4A017),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3D3D3D),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      menuItem.icon ?? Icons.fastfood,
                      size: 80,
                      color: const Color(0xFFD4A017),
                    ),
                  ),
                const SizedBox(height: 20),
                
                Text(
                  menuItem.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A017),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                Text(
                  menuItem.description,
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
                  'Harga: Rp ${_formatPrice(menuItem.price)}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFFD4A017),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                
                ElevatedButton.icon(
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
                    controller.addToCart(menuItem);
                    Navigator.pop(context); 
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}