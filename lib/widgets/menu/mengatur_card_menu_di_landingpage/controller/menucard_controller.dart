import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/menu_item.dart';

class MenuCardController extends GetxController with GetSingleTickerProviderStateMixin {
  final MenuItem item;
  
  late AnimationController animController;
  late Animation<double> scaleAnimation;
  late Animation<double> borderOpacityAnimation;
  late Animation<double> glowAnimation;
  late Animation<Color?> backgroundColorAnimation;

  MenuCardController({required this.item});

  @override
  void onInit() {
    super.onInit();
    
    animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeInOut),
    );

    borderOpacityAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeInOut),
    );

    glowAnimation = Tween<double>(begin: 5.0, end: 12.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeInOut),
    );

    backgroundColorAnimation = ColorTween(
      begin: const Color(0xFF2D2D2D),
      end: const Color(0xFF3D3D3D),
    ).animate(CurvedAnimation(parent: animController, curve: Curves.easeInOut));
  }

  void onTapDown() => animController.forward();
  
  void onTapUp() => animController.reverse();

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}