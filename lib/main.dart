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
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const LandingPage(),
    );
  }
}