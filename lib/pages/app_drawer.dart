import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/app/mengatur_tampilan_header_drawer/view/drawerheader_view.dart';
import '../widgets/app/mengatur_item_menu_dalam_drawer/view/drawermenu_view.dart';
import '../widgets/app/mengatur_dialog_pop-up_informasi_lokasi_toko/view/location_view.dart';
import '../widgets/app/mengatur_fungsi_buka_whatsapp/controller/whatsapp_controller.dart';
import '../data/controllers/theme_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final whatsappController = Get.put(WhatsAppController());
    final themeController = Get.find<ThemeController>();

    // Gunakan Obx agar warna latar belakang drawer bereaksi terhadap perubahan tema secara langsung
    return Obx(() => Drawer(
      // Latar belakang berubah berdasarkan status tema
      backgroundColor: themeController.isDarkMode.value ? const Color(0xFF2D2D2D) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. HEADER
          const DrawerHeaderView(),
          
          // 2. MENU UTAMA (Beranda)
          DrawerMenuView(
            icon: Icons.home,
            iconColor: const Color(0xFFD4A017),
            title: 'Beranda',
            // Warna teks menyesuaikan mode tema
            textColor: themeController.isDarkMode.value ? Colors.white : Colors.black87,
            onTap: () => Navigator.pop(context),
          ),
          
          const Divider(color: Colors.white24),
          
          // 3. MENU INFORMASI
          DrawerMenuView(
            icon: Icons.location_on,
            iconColor: Colors.red,
            title: 'Lokasi Toko',
            subtitle: 'Lihat lokasi warung kami',
            textColor: themeController.isDarkMode.value ? Colors.white : Colors.black87,
            onTap: () {
              Navigator.pop(context);
              LocationView.show(context);
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
          
          // ------------------------------------
          const Divider(color: Colors.white54), 
          // ------------------------------------

          // 4. FITUR TEMA (Menggunakan Shared Preferences)
          // Menggunakan Obx di sini agar tombol bisa berubah ikon/judul secara real-time
          Obx(() => DrawerMenuView(
            // Ikon dan warna berubah sesuai status tema
            icon: themeController.isDarkMode.value ? Icons.wb_sunny : Icons.nights_stay,
            iconColor: themeController.isDarkMode.value ? Colors.yellow : Colors.indigo,
            title: themeController.isDarkMode.value ? 'Mode Terang' : 'Mode Gelap',
            subtitle: 'Simpan preferensi tema aplikasi',
            textColor: themeController.isDarkMode.value ? Colors.white : Colors.black87,
            onTap: () {
              themeController.toggleTheme(); // Memanggil fungsi penyimpanan tema (Shared Preferences)
            },
          )),
          
          // Hapus semua logika dan impor untuk Login/Logout
        ],
      ),
    ));
}}