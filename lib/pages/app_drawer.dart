import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/app/mengatur_item_menu_dalam_drawer/view/drawermenu_view.dart';
import '../widgets/app/mengatur_fungsi_buka_whatsapp/controller/whatsapp_controller.dart';
import '../data/controllers/theme_controller.dart';
import '../data/controllers/auth_controller.dart';
import '../pages/location_selection_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final whatsappController = Get.put(WhatsAppController());
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Drawer(
        backgroundColor: themeController.isDarkMode.value
            ? const Color(0xFF2D2D2D)
            : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ✅ 1. CUSTOM DRAWER HEADER DENGAN BADGE ROLE (PALING ATAS)
            Obx(() {
              final authC = Get.find<AuthController>();
              return DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF2D2D2D), const Color(0xFF1A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.restaurant,
                      size: 50,
                      color: Color(0xFFD4A017),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bakso Ojolali Cakwi',
                      style: TextStyle(
                        color: Color(0xFFD4A017),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Makanan Enak, Harga Terjangkau',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        // Tampilkan badge role
                        if (authC.isLoggedIn)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: authC.isAdmin ? Colors.red : Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              authC.userRole.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            // ✅ 2. MENU BERANDA
            DrawerMenuView(
              icon: Icons.home,
              iconColor: const Color(0xFFD4A017),
              title: 'Beranda',
              textColor: themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black87,
              onTap: () => Navigator.pop(context),
            ),

            const Divider(color: Colors.white24),

            // ✅ 3. MENU LOKASI TOKO
            DrawerMenuView(
              icon: Icons.location_on,
              iconColor: Colors.red,
              title: 'Lokasi Toko',
              subtitle: 'Lihat lokasi warung kami',
              textColor: themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black87,
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const LocationSelectionPage());
              },
            ),

            // ✅ 4. MENU HUBUNGI KAMI
            DrawerMenuView(
              icon: Icons.chat,
              iconColor: const Color(0xFF8FBC8F),
              title: 'Hubungi Kami',
              subtitle: 'WhatsApp: +62 823-3757-7433',
              textColor: themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black87,
              onTap: () {
                Navigator.pop(context);
                whatsappController.openWhatsApp(context);
              },
            ),

            // ✅ 5. MENU JAM OPERASIONAL
            DrawerMenuView(
              icon: Icons.access_time,
              iconColor: Colors.blue,
              title: 'Jam Operasional',
              subtitle: 'Setiap Hari: 08.00 - 21.00',
              textColor: themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black87,
              onTap: () => Navigator.pop(context),
            ),

            const Divider(color: Colors.white54),

            // ✅ 6. TOGGLE THEME (PALING BAWAH)
            Obx(() => DrawerMenuView(
                  icon: themeController.isDarkMode.value
                      ? Icons.wb_sunny
                      : Icons.nights_stay,
                  iconColor: themeController.isDarkMode.value
                      ? Colors.yellow
                      : Colors.indigo,
                  title: themeController.isDarkMode.value
                      ? 'Mode Terang'
                      : 'Mode Gelap',
                  subtitle: 'Simpan preferensi tema aplikasi',
                  textColor: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black87,
                  onTap: () {
                    themeController.toggleTheme();
                  },
                )),
          ],
        ),
      ),
    );
  }
}