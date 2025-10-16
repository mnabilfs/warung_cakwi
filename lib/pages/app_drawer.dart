import 'package:flutter/material.dart';
import '../widgets/app/drawer_header_widget.dart';
import '../widgets/app/drawer_menu_item.dart';
import '../widgets/app/location_dialog.dart';
import '../widgets/app/whatsapp_launcher.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2D2D2D),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeaderWidget(),
          DrawerMenuItem(
            icon: Icons.home,
            iconColor: const Color(0xFFD4A017),
            title: 'Beranda',
            onTap: () => Navigator.pop(context),
          ),
          const Divider(color: Colors.white24),
          DrawerMenuItem(
            icon: Icons.location_on,
            iconColor: Colors.red,
            title: 'Lokasi Toko',
            subtitle: 'Lihat lokasi warung kami',
            onTap: () {
              Navigator.pop(context);
              LocationDialog.show(context);
            },
          ),
          DrawerMenuItem(
            icon: Icons.chat,
            iconColor: const Color(0xFF8FBC8F),
            title: 'Hubungi Kami',
            subtitle: 'WhatsApp: +62 823-3757-7433',
            onTap: () {
              Navigator.pop(context);
              WhatsAppLauncher.openWhatsApp(context);
            },
          ),
          DrawerMenuItem(
            icon: Icons.access_time,
            iconColor: Colors.blue,
            title: 'Jam Operasional',
            subtitle: 'Setiap Hari: 08.00 - 21.00',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}