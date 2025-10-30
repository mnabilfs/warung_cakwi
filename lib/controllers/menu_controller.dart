import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/menu_item.dart';
import '../services/api_service.dart'; // file saklar untuk http/dio

class MenuController extends GetxController {
  var menuItems = <MenuItem>[].obs;
  var cartItems = <MenuItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMenuItems();
  }

  Future<void> fetchMenuItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await ApiService.fetchMenuItems();
      menuItems.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void addToCart(MenuItem item) {
    cartItems.add(item);
    Get.snackbar(
      'Keranjang',
      '${item.name} ditambahkan ke keranjang',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2D2D2D),
      colorText: const Color(0xFFD4A017),
      margin: const EdgeInsets.all(10),
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
    }
  }
}
