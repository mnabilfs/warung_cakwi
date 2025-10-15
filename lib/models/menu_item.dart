import 'package:flutter/material.dart';

/// Model data untuk item menu
class MenuItem {
  final String name;
  final String description;
  final int price;
  final IconData icon;

  const MenuItem(this.name, this.description, this.price, this.icon);
}