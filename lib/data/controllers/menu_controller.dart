import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../models/menu_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
// Hapus import ApiService

class MenuController extends GetxController {
  var menuItems = <MenuItem>[].obs;
  var cartItems = <MenuItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Instance Supabase Client
  final _supabase = Supabase.instance.client;
  late Box<MenuItem> menuBox;
  late Box<MenuItem> cartBox;

  @override
  void onInit() async {
    menuBox = await Hive.openBox<MenuItem>('menu_cache');
    cartBox = await Hive.openBox<MenuItem>('cart_cache');

    // 2. MUAT DATA KERANJANG
    _loadCartFromLocal(); // 🔴 Muat data Keranjang saat start

    super.onInit();
    fetchMenuItems();
  }

  void _loadCartFromLocal() {
    // Muat semua item dari Box Hive ke Observable List
    cartItems.assignAll(cartBox.values.toList()); 
  }

  // --- FUNGSI LOKAL ---

  // Fungsi untuk menyimpan data yang sukses dari Supabase ke Hive
  Future<void> _saveMenuToLocal(List<MenuItem> items) async {
    await menuBox.clear(); // Bersihkan data lama
    await menuBox.addAll(items); // Tambahkan data baru
  }

  // Fungsi untuk memuat data dari Hive saat offline
  List<MenuItem> _loadMenuFromLocal() {
    return menuBox.values.toList();
  }

  // --- FUNGSI HYBRID FETCH ---

  Future<void> fetchMenuItems() async {
    try {
      isLoading.value = true;
      // 1. CLOUD-FIRST: Coba ambil dari Supabase
      final response = await _supabase.from('menu_items').select();

      final List<MenuItem> data = (response as List<dynamic>)
          .map((item) => MenuItem.fromJson(item))
          .toList();

      // 2. JIKA BERHASIL (ONLINE): SIMPAN KE HIVE & TAMPILKAN
      await _saveMenuToLocal(data); // Simpan ke lokal
      menuItems.assignAll(data);
      print("✅ Data diambil dari Supabase dan disimpan ke Hive.");
    } catch (e) {
      // 3. JIKA GAGAL (Mencatat error Supabase & melakukan Fallback)
      print("❌ ERROR SUPABASE TERCATAT: $e");

      final localData = _loadMenuFromLocal();

      if (localData.isNotEmpty) {
        // Tampilkan data lokal
        menuItems.assignAll(localData);
        Get.snackbar(
          "Mode Offline",
          "Menampilkan menu tersimpan lokal.",
          backgroundColor: Colors.amber,
          colorText: Colors.black,
        );
      } else {
        // Jika Hive juga kosong (pertama kali buka offline)
        Get.snackbar(
          "Error",
          "Tidak ada koneksi internet dan cache lokal kosong.",
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void addToCart(MenuItem item) {
    // Gunakan key unik (contoh: key terakhir + 1) untuk Insert ke Hive
    final int nextKey = (cartBox.keys.isEmpty ? 0 : cartBox.keys.last as int) + 1;
    cartBox.put(nextKey, item); 
    
    // Refresh List Observable dari Hive Box
    _loadCartFromLocal();

    // Snackbar code (tetap sama, tidak perlu diubah)
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A017).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFFD4A017),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ditambahkan ke Keranjang',
                  style: TextStyle(
                    color: Color(0xFFD4A017),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      messageText: const SizedBox.shrink(),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF2D2D2D),
      borderRadius: 12,
      margin: const EdgeInsets.only(top: 10, left: 12, right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      duration: const Duration(milliseconds: 1800),
      animationDuration: const Duration(milliseconds: 300),
      borderColor: const Color(0xFFD4A017).withOpacity(0.3),
      borderWidth: 1,
      isDismissible: true,
      dismissDirection: DismissDirection.up,
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
    );
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      // 🔴 PERUBAHAN UTAMA: Hapus dari Hive Box
      
      // 1. Dapatkan key Hive yang sesuai dengan index list yang ingin dihapus
      final keyToDelete = cartBox.keys.elementAt(index); 
      
      // 2. Lakukan Operasi Delete ke Hive Box (Modifikasi data lokal)
      cartBox.delete(keyToDelete); 
      
      // 3. Refresh List Observable dari Hive Box
      _loadCartFromLocal();
    }
  }
}
