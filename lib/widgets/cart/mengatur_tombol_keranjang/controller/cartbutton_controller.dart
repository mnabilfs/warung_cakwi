import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartButtonController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<double> scaleAnimation;
  late Animation<double> rotationAnimation;

  int previousCount = 0;

  @override
  void onInit() {
    super.onInit();
    
    animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: animController, curve: Curves.elasticOut));

    rotationAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeInOut),
    );
  }

  void updateItemCount(int newCount) {
    if (newCount > previousCount) {
      animController.forward(from: 0.0);
    }
    previousCount = newCount;
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}