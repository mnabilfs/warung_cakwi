import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'menu_item.g.dart';

@HiveType(typeId: 0)
class MenuItem {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int price;

  
  final IconData? icon; 
  
  @HiveField(4)
  final String? imageUrl;

  
  const MenuItem({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.icon,
    this.imageUrl,
  });

  
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    
    
    
    
    final priceValue = json['price'];
    int parsedPrice = 0;
    if (priceValue is num) {
      parsedPrice = priceValue.toInt();
    } else if (priceValue is String) {
      parsedPrice = int.tryParse(priceValue) ?? 0;
    }

    return MenuItem(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
      price: parsedPrice,
      imageUrl: json['image_url'] as String?,
      
      
      icon: null, 
    );
  }
}