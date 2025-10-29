import 'package:flutter/material.dart';

class MenuItem {
  final String name;
  final String description;
  final int price;
  final IconData? icon;
  final String? imageUrl;

  const MenuItem(this.name, this.description, this.price, this.icon, {this.imageUrl});
}