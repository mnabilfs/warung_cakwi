// lib/models/menu_item.dart
import 'package:flutter/material.dart';

class MenuItem {
  final String name;
  final String description;
  final int price;
  final IconData icon;

  MenuItem(this.name, this.description, this.price, this.icon);
}
