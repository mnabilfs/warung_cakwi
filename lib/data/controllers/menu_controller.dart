import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../models/menu_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth_controller.dart'; // Pastikan ini diimport

class MenuController extends GetxController {
  var menuItems = <MenuItem>[].obs;
  var cartItems = <MenuItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Map untuk menyimpan ID cart dari Supabase agar bisa dihapus nanti
  var cloudCartIds = <int, int>{}; 

  // Instance Supabase Client
  final _supabase = Supabase.instance.client;
  late Box<MenuItem> menuBox;
  late Box<MenuItem> cartBox;

  @override
  void onInit() async {
    super.onInit();
    // 1. Buka Hive (Kode Asli)
    menuBox = await Hive.openBox<MenuItem>('menu_cache');
    cartBox = await Hive.openBox<MenuItem>('cart_cache');

    // 2. Load Menu (Kode Asli)
    fetchMenuItems();

    // 3. Load Cart (Cek Login Status untuk menentukan sumber data)
    // Diberi delay sedikit agar AuthController siap
    Future.delayed(const Duration(milliseconds: 100), () {
       _checkAuthAndLoadCart();
    });
  }

  // Fungsi pembantu untuk mengecek status login
  void _checkAuthAndLoadCart() {
    // Cek apakah AuthController sudah dipasang di main.dart
    if (Get.isRegistered<AuthController>()) {
      final authC = Get.find<AuthController>();
      if (authC.isLoggedIn) {
        _fetchCartFromCloud(); // Jika Login -> Cloud
      } else {
        _loadCartFromLocal();  // Jika Tidak -> Hive (Kode Asli)
      }
    } else {
      _loadCartFromLocal(); // Fallback jika AuthController belum siap
    }
  }

  // Dipanggil dari AuthController saat user Login/Logout
  void handleAuthChange() {
    _checkAuthAndLoadCart();
  }

  // --- FUNGSI LOKAL (KODE ASLI ANDA - TETAP ADA) ---

  void _loadCartFromLocal() {
    cartItems.assignAll(cartBox.values.toList()); 
  }

  Future<void> _saveMenuToLocal(List<MenuItem> items) async {
    await menuBox.clear(); 
    await menuBox.addAll(items); 
  }

  List<MenuItem> _loadMenuFromLocal() {
    return menuBox.values.toList();
  }

  // --- FUNGSI FETCH CART CLOUD (BARU) ---
  
  Future<void> _fetchCartFromCloud() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Ambil data cart + detail menu (Join)
      final response = await _supabase
          .from('cart_items')
          .select('id, menu_id, menu_items(*)') 
          .eq('user_id', userId);

      final List<dynamic> data = response as List<dynamic>;
      List<MenuItem> loadedItems = [];
      cloudCartIds.clear(); 

      for (int i = 0; i < data.length; i++) {
        final itemData = data[i];
        final menuData = itemData['menu_items'];
        
        if (menuData != null) {
          loadedItems.add(MenuItem.fromJson(menuData));
          cloudCartIds[i] = itemData['id']; // Simpan ID untuk delete
        }
      }
      cartItems.assignAll(loadedItems);
    } catch (e) {
      print("Gagal sinkron cloud: $e");
      // Jangan timpa cartItems jika gagal, biarkan apa adanya atau kosong
    }
  }

  // --- FUNGSI HYBRID FETCH MENU (KODE ASLI ANDA - TETAP SAMA) ---

  Future<void> fetchMenuItems() async {
    try {
      isLoading.value = true;
      // 1. CLOUD-FIRST
      final response = await _supabase.from('menu_items').select();

      final List<MenuItem> data = (response as List<dynamic>)
          .map((item) => MenuItem.fromJson(item))
          .toList();

      // 2. SIMPAN KE LOKAL
      await _saveMenuToLocal(data); 
      menuItems.assignAll(data);
      print("✅ Data diambil dari Supabase dan disimpan ke Hive.");
    } catch (e) {
      // 3. FALLBACK ERROR (KODE ASLI)
      print("❌ ERROR SUPABASE TERCATAT: $e");

      final localData = _loadMenuFromLocal();

      if (localData.isNotEmpty) {
        menuItems.assignAll(localData);
        Get.snackbar(
          "Mode Offline",
          "Menampilkan menu tersimpan lokal.",
          backgroundColor: Colors.amber,
          colorText: Colors.black,
        );
      } else {
        Get.snackbar(
          "Error",
          "Tidak ada koneksi internet dan cache lokal kosong.",
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- ADD TO CART (DIMODIFIKASI SEDIKIT UNTUK DUKUNG CLOUD) ---

  @override
  void addToCart(MenuItem item) async {
    // Cek status login
    bool isUserLoggedIn = false;
    if (Get.isRegistered<AuthController>()) {
      isUserLoggedIn = Get.find<AuthController>().isLoggedIn;
    }

    if (isUserLoggedIn) {
      // --- JALUR CLOUD (Supabase) ---
      try {
        await _supabase.from('cart_items').insert({
          'user_id': _supabase.auth.currentUser!.id,
          'menu_id': item.id, 
          'quantity': 1
        });
        await _fetchCartFromCloud(); // Refresh UI
        _showCustomSnackbar(item); // Tampilkan Snackbar Asli Anda
      } catch (e) {
        Get.snackbar("Error", "Gagal simpan ke cloud: $e");
      }
    } else {
      // --- JALUR LOKAL (KODE ASLI HIVE ANDA) ---
      final int nextKey = (cartBox.keys.isEmpty ? 0 : cartBox.keys.last as int) + 1;
      cartBox.put(nextKey, item); 
      _loadCartFromLocal();
      _showCustomSnackbar(item); // Tampilkan Snackbar Asli Anda
    }
  }

  // --- REMOVE FROM CART (DIMODIFIKASI) ---

  void removeFromCart(int index) async {
     bool isUserLoggedIn = false;
    if (Get.isRegistered<AuthController>()) {
      isUserLoggedIn = Get.find<AuthController>().isLoggedIn;
    }

    if (index >= 0 && index < cartItems.length) {
      
      if (isUserLoggedIn) {
        // Hapus dari Cloud
        try {
          final cartIdToDelete = cloudCartIds[index];
          if (cartIdToDelete != null) {
            // Optimistic Update (Hapus dari UI dulu biar cepat)
            cartItems.removeAt(index); 
            await _supabase.from('cart_items').delete().eq('id', cartIdToDelete);
            _fetchCartFromCloud(); // Sync ulang untuk memastikan
          }
        } catch (e) {
          print("Gagal hapus cloud: $e");
        }
      } else {
        // Hapus dari Hive (KODE ASLI ANDA)
        final keyToDelete = cartBox.keys.elementAt(index); 
        cartBox.delete(keyToDelete); 
        _loadCartFromLocal();
      }
    }
  }

  // --- SNACKBAR ASLI ANDA (DIPISAH AGAR RAPI) ---
  void _showCustomSnackbar(MenuItem item) {
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
}