import 'package:flutter/material.dart';
import 'pages/landing_page.dart';

void main() => runApp(const WarungCakwiApp());

class WarungCakwiApp extends StatelessWidget {
  const WarungCakwiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warung Cakwi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFD4A017),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFD4A017),
          secondary: const Color(0xFFD4A017),
          surface: const Color(0xFF2D2D2D),
        ),
      ),
      home: const LandingPage(),
    );
  }
}