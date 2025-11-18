import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/landing_page.dart';
// import 'data/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'models/menu_item.dart';
import 'data/models/menu_item.dart';
import 'data/controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi controller sebelum runApp agar state tema tersedia
  Get.put(ThemeController());

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  Hive.registerAdapter(MenuItemAdapter());

  // 🔴 LANGKAH PENGUJIAN: HAPUS CACHE HIVE SECARA PAKSA (comment jika tidak di gunakan -> skenarion 2)
  // Ini memastikan Box 'menu_cache' benar-benar kosong saat aplikasi dimulai.
  // try {
  //   // Memastikan Box dihapus sebelum dibuka
  //   await Hive.deleteBoxFromDisk('menu_cache');
  //   print("✅ Cache Hive 'menu_cache' berhasil dihapus untuk pengujian skenario 2.");
  // } catch (e) {
  //   print("Gagal menghapus cache Hive: $e");
  // }

  // 1. Inisialisasi Supabase
  await Supabase.initialize(
    // Gunakan dotenv.env['NAMA_VARIABLE']! untuk mengakses nilai
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    // Tanda seru (!) digunakan karena kita yakin variabel tersebut ada di .env
  );

  // Jalankan simulasi chaining sebelum aplikasi dimulai
  // await ApiService.loadAndProcessMenu();

  runApp(const WarungCakwiApp());
}

class WarungCakwiApp extends StatelessWidget {
  const WarungCakwiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Warung Cakwi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Definisikan Light Theme
      darkTheme: ThemeData.dark().copyWith(
        // Definisikan Dark Theme
        primaryColor: const Color(0xFFD4A017),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4A017),
          secondary: Color(0xFFD4A017),
          surface: Color(0xFF2D2D2D),
        ),
      ),
      // Hubungkan themeMode ke status isDarkMode
      themeMode: themeController.isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,
      home: LandingPage(),
    );
  }
}
