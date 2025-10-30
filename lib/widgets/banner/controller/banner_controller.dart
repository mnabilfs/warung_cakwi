import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<double> floatAnimation;
  late Animation<double> rotateAnimation;

  final String title = 'Bakso Ojolali Cakwi';
  final String subtitle = 'Daftar Menu Terlengkap';
  final String badge = '⭐ Menerima Pesanan';

  @override
  void onInit() {
    super.onInit();
    
    animController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeInOut),
    );

    rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeInOut),
    );
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}