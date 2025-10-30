import 'package:get/get.dart';
import '../controller/drawermenu_controller.dart';
import 'package:flutter/material.dart';

class DrawerMenuBindings extends Bindings {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;

  DrawerMenuBindings({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
  });

  @override
  void dependencies() {
    Get.lazyPut<DrawerMenuController>(
      () => DrawerMenuController(
        icon: icon,
        iconColor: iconColor,
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}