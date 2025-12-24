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
<<<<<<< HEAD
import '../utils/error_helper.dart'; // ✅ ERROR RECOVERY
=======
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0

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
<<<<<<< HEAD
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
=======
        backgroundColor: const Color(0xFF2D2D2D),
        iconTheme: const IconThemeData(color: Color(0xFFD4A017)), 
        actions: [
          Obx(() {
            if (authC.isAdmin) {
              return IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: Color(0xFFD4A017)),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
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
<<<<<<< HEAD
            icon: Icon(Icons.logout, color: colorScheme.primary),
=======
            icon: const Icon(Icons.logout, color: Color(0xFFD4A017)),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
            tooltip: "Keluar Aplikasi",
            onPressed: () {
              Get.defaultDialog(
                title: "Logout",
<<<<<<< HEAD
                titleStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                middleText: "Apakah Anda yakin ingin keluar?",
                middleTextStyle: TextStyle(color: colorScheme.onSurface),
                backgroundColor: colorScheme.surfaceContainerHighest,
                textConfirm: "Ya, Keluar",
                textCancel: "Batal",
                confirmTextColor: colorScheme.onPrimary,
                buttonColor: colorScheme.primary,
                cancelTextColor: colorScheme.primary,
=======
                titleStyle: const TextStyle(color: Color(0xFFD4A017), fontWeight: FontWeight.bold),
                middleText: "Apakah Anda yakin ingin keluar?",
                middleTextStyle: const TextStyle(color: Colors.white),
                backgroundColor: const Color(0xFF2D2D2D),
                textConfirm: "Ya, Keluar",
                textCancel: "Batal",
                confirmTextColor: Colors.black,
                buttonColor: const Color(0xFFD4A017),
                cancelTextColor: const Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
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
<<<<<<< HEAD
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        } else if (controller.errorMessage.isNotEmpty) {
          // ✅ ERROR RECOVERY: Use ErrorStateWidget with retry
          return ErrorStateWidget(
            errorMessage: controller.errorMessage.value,
            onRetry: () => controller.fetchMenuItems(),
          );
        } else if (controller.menuItems.isEmpty) {
          return Center(child: Text('Tidak ada data.', 
              style: TextStyle(color: colorScheme.onSurface)));
        }

        // ✅ FLEXIBILITY: Use filtered items for search
        final items = controller.filteredMenuItems;
=======
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
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0

        return SingleChildScrollView(
          child: Column(
            children: [
<<<<<<< HEAD
              // 🔍 MARKER: SEARCH_BAR
              // ✅ FLEXIBILITY: Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Cari menu favorit...',
                    hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                    suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: colorScheme.onSurface.withOpacity(0.5)),
                            onPressed: () {
                              controller.clearSearch();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : const SizedBox.shrink()),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                ),
              ),
              
              const BannerView(),
              
              // ✅ FLEXIBILITY: Show search results count when searching
              if (controller.searchQuery.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Ditemukan ${items.length} menu',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // ✅ FLEXIBILITY: Empty state for no search results
              if (items.isEmpty && controller.searchQuery.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Menu tidak ditemukan',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coba kata kunci lain',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                )
              else
                _buildMenuSection(context, items),
=======
              const BannerView(),
              _buildMenuSection(items),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
            ],
          ),
        );
      }),
    );
  }

  // ... rest of the code remains the same ...
  
<<<<<<< HEAD
Widget _buildMenuSection(BuildContext context, List items) {
=======
Widget _buildMenuSection(List items) {
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
  return LayoutBuilder(
    builder: (context, constraints) {
      final bool isWide = constraints.maxWidth > 600;
      final int crossAxisCount = isWide ? 2 : 1;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ TAMBAHAN BARU: AI Recommendation Banner
          const AIRecommendationBanner(),
          
<<<<<<< HEAD
          _buildSectionHeader(context),
=======
          _buildSectionHeader(),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
          _buildMenuGrid(context, items, crossAxisCount, isWide),
          const SizedBox(height: 20), 
        ],
      );
    },
  );
}

<<<<<<< HEAD
  Widget _buildSectionHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
=======
  Widget _buildSectionHeader() {
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
<<<<<<< HEAD
              color: colorScheme.primary,
=======
              color: const Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
<<<<<<< HEAD
          Text(
            'Menu Pilihan',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
=======
          const Text(
            'Menu Pilihan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
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
<<<<<<< HEAD
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
=======
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
    return GestureDetector(
      onTap: () => _showMenuDetail(context, menuItem),
      child: Container(
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: colorScheme.surfaceContainerHighest,
=======
          color: const Color(0xFF2D2D2D),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
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
<<<<<<< HEAD
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
=======
                    color: const Color(0xFF3D3D3D),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.5)),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
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
<<<<<<< HEAD
                                  color: colorScheme.primary,
=======
                                  color: const Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                menuItem.icon ?? Icons.fastfood,
<<<<<<< HEAD
                                color: colorScheme.primary,
=======
                                color: const Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                                size: 30,
                              );
                            },
                          )
                        : Icon(
                            menuItem.icon ?? Icons.fastfood,
<<<<<<< HEAD
                            color: colorScheme.primary,
=======
                            color: const Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
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
<<<<<<< HEAD
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
=======
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menuItem.description,
<<<<<<< HEAD
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
=======
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
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
<<<<<<< HEAD
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
=======
                    style: const TextStyle(
                      color: Color(0xFFD4A017),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
<<<<<<< HEAD
                      color: colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_shopping_cart,
                      color: colorScheme.primary,
=======
                      color: const Color(0xFFD4A017).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
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
<<<<<<< HEAD
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
=======
    showDialog(
      context: context,
      builder: (context) => Dialog(
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
<<<<<<< HEAD
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.3),
=======
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4A017).withOpacity(0.3),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
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
<<<<<<< HEAD
                              color: colorScheme.primary,
=======
                              color: const Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
<<<<<<< HEAD
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
=======
                          decoration: const BoxDecoration(
                            color: Color(0xFF3D3D3D),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                          ),
                          child: Icon(
                            menuItem.icon ?? Icons.fastfood,
                            size: 80,
<<<<<<< HEAD
                            color: colorScheme.primary,
=======
                            color: const Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
<<<<<<< HEAD
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
=======
                    decoration: const BoxDecoration(
                      color: Color(0xFF3D3D3D),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      menuItem.icon ?? Icons.fastfood,
                      size: 80,
<<<<<<< HEAD
                      color: colorScheme.primary,
=======
                      color: const Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                    ),
                  ),
                const SizedBox(height: 20),
                
                Text(
                  menuItem.name,
<<<<<<< HEAD
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
=======
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                Text(
                  menuItem.description,
                  textAlign: TextAlign.center,
<<<<<<< HEAD
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
=======
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  height: 1,
                  width: double.infinity,
<<<<<<< HEAD
                  color: colorScheme.primary.withOpacity(0.3),
=======
                  color: const Color(0xFFD4A017).withOpacity(0.3),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Harga: Rp ${_formatPrice(menuItem.price)}',
<<<<<<< HEAD
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
=======
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFFD4A017),
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                
<<<<<<< HEAD
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
=======
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
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
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