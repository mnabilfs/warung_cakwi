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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Bakso Ojolali Cakwi',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
        iconTheme: IconThemeData(color: colorScheme.primary), 
        actions: [
          Obx(() {
            // Access observable directly for GetX to track
            final profile = authC.currentProfile.value;
            final isAdmin = profile?.isAdmin ?? false;
            
            if (isAdmin) {
              return IconButton(
                icon: Icon(Icons.admin_panel_settings, color: colorScheme.primary),
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
            icon: Icon(Icons.logout, color: colorScheme.primary),
            tooltip: "Keluar Aplikasi",
            onPressed: () {
              Get.defaultDialog(
                title: "Logout",
                titleStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                middleText: "Apakah Anda yakin ingin keluar?",
                middleTextStyle: TextStyle(color: colorScheme.onSurface),
                backgroundColor: colorScheme.surfaceContainerHighest,
                textConfirm: "Ya, Keluar",
                textCancel: "Batal",
                confirmTextColor: colorScheme.onPrimary,
                buttonColor: colorScheme.primary,
                cancelTextColor: colorScheme.primary,
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
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        } else if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text('Gagal memuat data: ${controller.errorMessage}', 
              style: TextStyle(color: colorScheme.onSurface)),
          );
        } else if (controller.menuItems.isEmpty) {
          return Center(child: Text('Tidak ada data.', 
              style: TextStyle(color: colorScheme.onSurface)));
        }

        final items = controller.menuItems;

        return SingleChildScrollView(
          child: Column(
            children: [
              const BannerView(),
              _buildMenuSection(context, items),
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

  Widget _buildSectionHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Menu Pilihan',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return GestureDetector(
      onTap: () => _showMenuDetail(context, menuItem),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
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
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
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
                                  color: colorScheme.primary,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                menuItem.icon ?? Icons.fastfood,
                                color: colorScheme.primary,
                                size: 30,
                              );
                            },
                          )
                        : Icon(
                            menuItem.icon ?? Icons.fastfood,
                            color: colorScheme.primary,
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
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menuItem.description,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
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
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_shopping_cart,
                      color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.3),
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
                              color: colorScheme.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Icon(
                            menuItem.icon ?? Icons.fastfood,
                            size: 80,
                            color: colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      menuItem.icon ?? Icons.fastfood,
                      size: 80,
                      color: colorScheme.primary,
                    ),
                  ),
                const SizedBox(height: 20),
                
                Text(
                  menuItem.name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                Text(
                  menuItem.description,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  height: 1,
                  width: double.infinity,
                  color: colorScheme.primary.withOpacity(0.3),
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Harga: Rp ${_formatPrice(menuItem.price)}',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                
                // The ElevatedButton will use theme automatically
                ElevatedButton.icon(
                  onPressed: () {
                    controller.addToCart(menuItem);
                    Navigator.pop(dialogContext); 
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    'Tambah ke Keranjang',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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