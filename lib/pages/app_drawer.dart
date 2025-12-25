import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/app/mengatur_item_menu_dalam_drawer/view/drawermenu_view.dart';
import '../widgets/app/mengatur_fungsi_buka_whatsapp/controller/whatsapp_controller.dart';
import '../data/controllers/theme_controller.dart';
import '../data/controllers/auth_controller.dart';
import '../widgets/app/mengatur_dialog_pop-up_informasi_lokasi_toko/view/location_view.dart';
import '../widgets/app/mengatur_dialog_pop-up_informasi_lokasi_toko/bindings/location_binding.dart';

import '../pages/weather_recommendation_page.dart';
import '../pages/help_page.dart';
import '../pages/user_orders_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final whatsappController = Get.put(WhatsAppController());
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. CUSTOM DRAWER HEADER DENGAN BADGE ROLE
          Obx(() {
            final authC = Get.find<AuthController>();
            final user = authC.currentUser.value;
            final profile = authC.currentProfile.value;
            final isLoggedIn = user != null;
            final isAdmin = profile?.isAdmin ?? false;
            final role = profile?.role ?? 'user';

            return DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surfaceContainerHighest,
                    colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.restaurant, size: 50, color: colorScheme.primary),
                  const SizedBox(height: 10),
                  Text(
                    'Bakso Ojolali Cakwi',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Makanan Enak, Harga Terjangkau',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isLoggedIn)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? colorScheme.error
                                : colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: isAdmin
                                  ? colorScheme.onError
                                  : colorScheme.onTertiary,
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

          // 2. MENU BERANDA
          DrawerMenuView(
            icon: Icons.home,
            iconColor: colorScheme.primary,
            title: 'Beranda',
            textColor: colorScheme.onSurface,
            onTap: () => Navigator.pop(context),
          ),

          Divider(color: colorScheme.outline.withOpacity(0.3)),

          // 3. MENU LOKASI TOKO
          DrawerMenuView(
            icon: Icons.location_on,
            iconColor: colorScheme.error,
            title: 'Lokasi Toko',
            subtitle: 'Lihat lokasi warung kami',
            textColor: colorScheme.onSurface,
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const LocationView(), binding: LocationBinding());
            },
          ),

          // 4. MENU HUBUNGI KAMI
          DrawerMenuView(
            icon: Icons.chat,
            iconColor: const Color(0xFF8FBC8F),
            title: 'Hubungi Kami',
            subtitle: 'WhatsApp: +62 823-3757-7433',
            textColor: colorScheme.onSurface,
            onTap: () {
              Navigator.pop(context);
              whatsappController.openWhatsApp(context);
            },
          ),

          DrawerMenuView(
            icon: Icons.history,
            iconColor: Colors.amber,
            title: 'Riwayat Pesanan',
            subtitle: 'Lihat pesanan Anda',
            textColor: colorScheme.onSurface,
            onTap: () {
              Navigator.pop(context);
              Get.to(() => UserOrdersPage());
            },
          ),

          // 3.5. MENU REKOMENDASI CUACA & MENU
          DrawerMenuView(
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            title: 'Rekomendasi AI',
            subtitle: 'Cuaca & menu hari ini',
            textColor: colorScheme.onSurface,
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const WeatherRecommendationPage());
            },
          ),

          // 5. MENU JAM OPERASIONAL
          DrawerMenuView(
            icon: Icons.access_time,
            iconColor: Colors.blue,
            title: 'Jam Operasional',
            subtitle: 'Setiap Hari: 08.00 - 21.00',
            textColor: colorScheme.onSurface,
            onTap: () => Navigator.pop(context),
          ),

          // 6. MENU BANTUAN (HELP & DOCUMENTATION)
          DrawerMenuView(
            icon: Icons.help_outline,
            iconColor: Colors.teal,
            title: 'Bantuan',
            subtitle: 'FAQ & Hubungi Kami',
            textColor: colorScheme.onSurface,
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const HelpPage());
            },
          ),

          Divider(color: colorScheme.outline.withOpacity(0.5)),

          // 7. TOGGLE THEME
          Obx(
            () => DrawerMenuView(
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
              textColor: colorScheme.onSurface,
              onTap: () {
                themeController.toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}