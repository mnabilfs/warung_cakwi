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

  // Field ini tidak disimpan di DB, hanya untuk UI/Fallback. Boleh tidak diberi @HiveField
  final IconData? icon; 
  
  @HiveField(4)
  final String? imageUrl;

  // Constructor menggunakan named arguments (standar Flutter/Dart yang lebih baik)
  const MenuItem({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.icon,
    this.imageUrl,
  });

  // Factory Constructor untuk memetakan data dari Supabase (JSON/Map)
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Supabase mengembalikan List<Map<String, dynamic>>
    // Kita petakan kolom database ke properti Dart:
    
    // Konversi price dari num (tipe data fleksibel DB) ke int
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
      // Icon akan diset null karena data ini tidak ada di DB, 
      // nanti di UI kita bisa gunakan IconData default jika imageUrl kosong.
      icon: null, 
    );
  }
}