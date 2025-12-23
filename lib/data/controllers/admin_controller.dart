import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_item.dart';

class AdminController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  var menuItems = <MenuItem>[].obs;
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
      
      final response = await _supabase.from('menu_items').select().order('id');
      final List<MenuItem> data = (response as List<dynamic>)
          .map((item) => MenuItem.fromJson(item))
          .toList();
      
      menuItems.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
      if (kDebugMode) print('❌ Fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createMenuItem({
    required String name,
    required String description,
    required int price,
    String? imageUrl,
  }) async {
    try {
      isLoading.value = true;
      await _supabase.from('menu_items').insert({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
      });
      
      await fetchMenuItems();
      Get.snackbar('Berhasil', 'Menu berhasil ditambahkan',
          backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMenuItem({
    required int id,
    required String name,
    required String description,
    required int price,
    String? imageUrl,
  }) async {
    try {
      isLoading.value = true;
      await _supabase.from('menu_items').update({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
      }).eq('id', id);
      
      await fetchMenuItems();
      Get.snackbar('Berhasil', 'Menu berhasil diupdate',
          backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteMenuItem(int id) async {
    try {
      isLoading.value = true;
      await _supabase.from('menu_items').delete().eq('id', id);
      
      await fetchMenuItems();
      Get.snackbar('Berhasil', 'Menu berhasil dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}