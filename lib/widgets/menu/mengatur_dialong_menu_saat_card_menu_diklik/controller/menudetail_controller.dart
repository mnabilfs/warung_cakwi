import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/menu_item.dart';

class MenuDetailController extends GetxController with GetSingleTickerProviderStateMixin {
  final MenuItem menuItem;
  
  late AnimationController animController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> iconRotateAnimation;

  var isButtonPressed = false.obs;

  MenuDetailController({required this.menuItem});

  @override
  void onInit() {
    super.onInit();

    animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animController, curve: Curves.elasticOut));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animController, curve: Curves.easeIn));

    iconRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 6.28,
    ).animate(CurvedAnimation(parent: animController, curve: Curves.easeInOut));

    animController.forward();
  }

  void pressButton() {
    isButtonPressed.value = true;
  }

  void releaseButton() {
    isButtonPressed.value = false;
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}