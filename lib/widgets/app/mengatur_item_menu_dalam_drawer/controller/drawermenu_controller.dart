import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawerMenuController extends GetxController {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;

  DrawerMenuController({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
  });
}