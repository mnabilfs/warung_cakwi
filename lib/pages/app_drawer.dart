import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/app/mengatur_tampilan_header_drawer/view/drawerheader_view.dart';
import '../widgets/app/mengatur_item_menu_dalam_drawer/view/drawermenu_view.dart';
// import '../widgets/app/mengatur_dialog_pop-up_informasi_lokasi_toko/view/location_view.dart';
import '../widgets/app/mengatur_fungsi_buka_whatsapp/controller/whatsapp_controller.dart';
import '../data/controllers/theme_controller.dart';
import '../pages/location_selection_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final whatsappController = Get.put(WhatsAppController());
    final themeController = Get.find<ThemeController>();

    
    return Obx(() => Drawer(
      
      backgroundColor: themeController.isDarkMode.value ? const Color(0xFF2D2D2D) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          
          const DrawerHeaderView(),
          
          
          DrawerMenuView(
            icon: Icons.home,
            iconColor: const Color(0xFFD4A017),
            title: 'Beranda',
            
            textColor: themeController.isDarkMode.value ? Colors.white : Colors.black87,
            onTap: () => Navigator.pop(context),
          ),
          
          const Divider(color: Colors.white24),
          
          
          DrawerMenuView(
            icon: Icons.location_on,
            iconColor: Colors.red,
            title: 'Lokasi Toko',
            subtitle: 'Lihat lokasi warung kami',
            textColor: themeController.isDarkMode.value ? Colors.white : Colors.black87,
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const LocationSelectionPage());
            },
          ),
          
          DrawerMenuView(
            icon: Icons.chat,
            iconColor: const Color(0xFF8FBC8F),
            title: 'Hubungi Kami',
            subtitle: 'WhatsApp: +62 823-3757-7433',
            textColor: themeController.isDarkMode.value ? Colors.white : Colors.black87,
            onTap: () {
              Navigator.pop(context);
              whatsappController.openWhatsApp(context);
            },
          ),
          
          DrawerMenuView(
            icon: Icons.access_time,
            iconColor: Colors.blue,
            title: 'Jam Operasional',
            subtitle: 'Setiap Hari: 08.00 - 21.00',
            textColor: themeController.isDarkMode.value ? Colors.white : Colors.black87,
            onTap: () => Navigator.pop(context),
          ),
          
          
          const Divider(color: Colors.white54), 
          

          
          
          Obx(() => DrawerMenuView(
            
            icon: themeController.isDarkMode.value ? Icons.wb_sunny : Icons.nights_stay,
            iconColor: themeController.isDarkMode.value ? Colors.yellow : Colors.indigo,
            title: themeController.isDarkMode.value ? 'Mode Terang' : 'Mode Gelap',
            subtitle: 'Simpan preferensi tema aplikasi',
            textColor: themeController.isDarkMode.value ? Colors.white : Colors.black87,
            onTap: () {
              themeController.toggleTheme(); 
            },
          )),
          
          
        ],
      ),
    ));
}}