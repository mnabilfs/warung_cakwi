import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../models/menu_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth_controller.dart';

class MenuController extends GetxController {
  var menuItems = <MenuItem>[].obs;
  var cartItems = <MenuItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs; // Variabel error

  // Map ID Cloud (Key: Index List, Value: ID Table Supabase)
  var cloudCartIds = <int, int>{}; 

  final _supabase = Supabase.instance.client;
  late Box<MenuItem> menuBox;
  late Box<MenuItem> cartBox;

  @override
  void onInit() async {
    super.onInit();
    // 1. Buka Database Lokal
    menuBox = await Hive.openBox<MenuItem>('menu_cache');
    cartBox = await Hive.openBox<MenuItem>('cart_cache');

    // 2. Load Awal (Biar layar tidak kosong)
    fetchMenuItems();
    _loadCartFromLocal();

    // 3. Sinkronisasi Cerdas (Tunggu Auth siap)
    Future.delayed(const Duration(milliseconds: 500), () {
       _checkAuthAndSync();
    });
  }

  void handleAuthChange() {
    _checkAuthAndSync();
  }

  void _checkAuthAndSync() async {
    if (Get.isRegistered<AuthController>()) {
      final authC = Get.find<AuthController>();
      if (authC.isLoggedIn) {
        // --- LOGIKA SINKRONISASI ---
        
        // 1. SYNC UP (Offline -> Cloud)
        // Upload data lokal ke cloud, TAPI cek dulu biar gak double
        if (cartBox.isNotEmpty) {
           await _uploadLocalToCloud();
        }

        // 2. SYNC DOWN (Cloud -> Offline)
        // Paksa data lokal mengikuti Cloud agar HP A & B sama persis
        await _fetchCartFromCloud(); 
      }
    }
  }

  // --- FUNGSI UPLOAD CERDAS (ANTI DUPLIKAT) ---
  Future<void> _uploadLocalToCloud() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final localItems = cartBox.values.toList();
      
      if (localItems.isNotEmpty) {
        print("🔄 Cek data offline sebelum upload...");

        // Ambil daftar ID menu yang SUDAH ada di Cloud
        final existingData = await _supabase
            .from('cart_items')
            .select('menu_id')
            .eq('user_id', userId);
        
        // Masukkan ke dalam Set biar pengecekan cepat
        final existingMenuIds = (existingData as List)
            .map((e) => e['menu_id'] as int)
            .toSet();

        for (var item in localItems) {
           // KUNCI PERBAIKAN: Jika menu ini sudah ada di cloud, SKIP!
           if (existingMenuIds.contains(item.id)) {
             continue; 
           }

           // Jika belum ada, baru upload
           await _supabase.from('cart_items').insert({
            'user_id': userId,
            'menu_id': item.id, 
            'quantity': 1
          });
        }
        // Setelah upload, kosongkan lokal. Nanti diisi ulang oleh _fetchCartFromCloud
        await cartBox.clear(); 
      }
    } catch (e) {
      print("⚠️ Gagal Upload Offline: $e");
    }
  }

  // --- FUNGSI DOWNLOAD & SAMAKAN DATA (SYNC DOWN) ---
  Future<void> _fetchCartFromCloud() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      final response = await _supabase
          .from('cart_items')
          .select('id, menu_id, menu_items(*)') 
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      List<MenuItem> loadedItems = [];
      cloudCartIds.clear(); 

      for (int i = 0; i < data.length; i++) {
        final itemData = data[i];
        final menuData = itemData['menu_items'];
        
        if (menuData != null) {
          loadedItems.add(MenuItem.fromJson(menuData));
          cloudCartIds[i] = itemData['id']; 
        }
      }
      
      // 1. Update Tampilan (UI)
      cartItems.assignAll(loadedItems);

      // 2. Update HIVE (Lokal)
      // Hapus semua data lokal, ganti dengan data Cloud terbaru
      // Ini yang bikin HP A dan HP B jadi SAMA PERSIS.
      await cartBox.clear();
      for (var item in loadedItems) {
        await cartBox.add(item);
      }

    } catch (e) {
      print("⚠️ Gagal ambil Cloud. Tetap pakai data lokal.");
    }
  }

  void _loadCartFromLocal() {
    if (cartBox.isNotEmpty) {
      cartItems.assignAll(cartBox.values.toList());
    } else {
      cartItems.clear();
    }
  }

  // --- ADD TO CART ---
  @override
  void addToCart(MenuItem item) async {
    bool isUserLoggedIn = false;
    if (Get.isRegistered<AuthController>()) {
      isUserLoggedIn = Get.find<AuthController>().isLoggedIn;
    }

    if (isUserLoggedIn) {
      try {
        // Online: Kirim ke Cloud
        await _supabase.from('cart_items').insert({
          'user_id': _supabase.auth.currentUser!.id,
          'menu_id': item.id, 
          'quantity': 1
        });
        // Tarik ulang biar sinkron
        await _fetchCartFromCloud(); 
        _showSuccessSnackbar(item.name, "Tersimpan di Cloud");
      } catch (e) {
        // Offline: Simpan Lokal
        print("⚠️ Offline Fallback");
        cartItems.add(item);
        await cartBox.add(item); 
        _showOfflineSnackbar(); 
      }
    } else {
      // Guest
      cartItems.add(item);
      await cartBox.add(item);
      _showOfflineSnackbar();
    }
  }

  // --- REMOVE FROM CART ---
  void removeFromCart(int index) async {
     bool isUserLoggedIn = false;
    if (Get.isRegistered<AuthController>()) {
      isUserLoggedIn = Get.find<AuthController>().isLoggedIn;
    }

    if (index < cartItems.length) cartItems.removeAt(index);

    if (isUserLoggedIn) {
      try {
        final cartIdToDelete = cloudCartIds[index];
        if (cartIdToDelete != null) {
          await _supabase.from('cart_items').delete().eq('id', cartIdToDelete);
          await _fetchCartFromCloud(); 
        } else {
          await _fetchCartFromCloud();
        }
      } catch (e) {
        if (index < cartBox.length) await cartBox.deleteAt(index);
        _showOfflineSnackbar();
      }
    } else {
      if (index < cartBox.length) await cartBox.deleteAt(index);
    }
  }

  Future<void> fetchMenuItems() async {
    try {
      isLoading.value = true;
      final response = await _supabase.from('menu_items').select();
      final List<MenuItem> data = (response as List<dynamic>)
          .map((item) => MenuItem.fromJson(item))
          .toList();

      await menuBox.clear();
      await menuBox.addAll(data);
      menuItems.assignAll(data);
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = e.toString();
      if (menuBox.isNotEmpty) {
        menuItems.assignAll(menuBox.values.toList());
        errorMessage.value = '';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showOfflineSnackbar() {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      "Mode Offline",
      "Disimpan di penyimpanan lokal (Hive)",
      icon: const Icon(Icons.wifi_off, color: Colors.white),
      backgroundColor: Colors.redAccent.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

  void _showSuccessSnackbar(String itemName, String subtitle) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      "Sukses",
      "$itemName - $subtitle",
      icon: const Icon(Icons.cloud_done, color: Colors.white),
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }
}