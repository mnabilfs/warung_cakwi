import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/landing_page.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Jalankan simulasi chaining sebelum aplikasi dimulai
  await ApiService.loadAndProcessMenu();

  runApp(const WarungCakwiApp());
}

class WarungCakwiApp extends StatelessWidget {
  const WarungCakwiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Warung Cakwi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFD4A017),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4A017),
          secondary: Color(0xFFD4A017),
          surface: Color(0xFF2D2D2D),
        ),
      ),
      home: LandingPage(),
    );
  }
}
