import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/app/drawerheader/view/drawerheader_view.dart';
import '../widgets/app/drawermenu/view/drawermenu_view.dart';
import '../widgets/app/location/view/location_view.dart';
import '../widgets/app/whatsapp/controller/whatsapp_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final whatsappController = Get.put(WhatsAppController());

    return Drawer(
      backgroundColor: const Color(0xFF2D2D2D),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeaderView(),
          
          DrawerMenuView(
            icon: Icons.home,
            iconColor: const Color(0xFFD4A017),
            title: 'Beranda',
            onTap: () => Navigator.pop(context),
          ),
          
          const Divider(color: Colors.white24),
          
          DrawerMenuView(
            icon: Icons.location_on,
            iconColor: Colors.red,
            title: 'Lokasi Toko',
            subtitle: 'Lihat lokasi warung kami',
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
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}