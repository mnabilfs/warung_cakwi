import 'package:flutter/material.dart';
import 'package:gerai_bakso/pages/landing_page.dart';

void main() {
  runApp(const BaksoApp());
}

class BaksoApp extends StatelessWidget {
  const BaksoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warung Ojalali Cakwi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        useMaterial3: true,
      ),
       home: const LandingPage(),
    );
  }
}
