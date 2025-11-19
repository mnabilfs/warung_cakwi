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
  var errorMessage = ''.obs;

  // Map ID Cloud untuk penghapusan (Key: Index List, Value: ID Table Supabase)
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

    // 2. Load Menu & Cart Lokal Dulu (Supaya tidak loading lama)
    fetchMenuItems();
    _loadCartFromLocal();

    // 3. Cek Login & Mulai Sinkronisasi Cloud
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
        // --- LOGIKA UTAMA SINKRONISASI ---
        
        // 1. SYNC UP (Offline -> Cloud)
        // Jika ada data di HP (hasil belanja offline) yang belum ada di Cloud,
        // kita upload dulu agar tidak hilang.
        if (cartBox.isNotEmpty) {
           await _uploadLocalToCloud();
        }

        // 2. SYNC DOWN (Cloud -> Offline/UI)
        // Ini yang memperbaiki masalah "Beda Device".
        // Kita paksa data di HP ini mengikuti data terbaru dari Server.
        await _fetchCartFromCloud(); 
      }
    }
  }

  // --- FUNGSI UPLOAD (OFFLINE -> ONLINE) ---
  Future<void> _uploadLocalToCloud() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final localItems = cartBox.values.toList();
      
      // Cek: Jika Cloud kosong, berarti ini murni data offline, kita upload semua.
      // Jika Cloud sudah ada isinya, kita harus hati-hati agar tidak duplikat.
      // CARA AMAN: Kita anggap data lokal adalah tambahan baru.
      
      // Namun, untuk mencegah duplikasi parah saat restart berkali-kali,
      // kita cek dulu apakah item ini sudah ada? (Simplifikasi: Upload saja, nanti user bisa hapus)
      
      if (localItems.isNotEmpty) {
        print("🔄 Uploading data offline ke Cloud...");
        for (var item in localItems) {
           // Insert satu per satu
           await _supabase.from('cart_items').insert({
            'user_id': userId,
            'menu_id': item.id, 
            'quantity': 1
          });
        }
        // Setelah sukses upload, kita kosongkan lokal SEMENTARA.
        // Nanti lokal akan diisi ulang oleh _fetchCartFromCloud dengan data yang rapi + ID Cloud.
        await cartBox.clear(); 
      }
    } catch (e) {
      print("⚠️ Gagal Upload Offline: $e");
    }
  }

  // --- FUNGSI DOWNLOAD (ONLINE -> OFFLINE) ---
  Future<void> _fetchCartFromCloud() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Tarik data terbaru dari Server
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
          cloudCartIds[i] = itemData['id']; // Simpan ID Cloud
        }
      }
      
      // 1. Update UI
      cartItems.assignAll(loadedItems);

      // 2. Update Hive (Timpa data lokal dengan data Cloud yang valid)
      // Ini menjamin HP A dan HP B isinya SAMA.
      await cartBox.clear();
      for (var item in loadedItems) {
        await cartBox.add(item);
      }
      
      print("✅ Sinkronisasi Selesai (Cloud -> Lokal)");

    } catch (e) {
      print("⚠️ Gagal ambil Cloud (Mungkin Offline). Tetap pakai data lokal.");
      // Jangan hapus data lokal jika gagal konek
      _showOfflineSnackbar();
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
      // ONLINE MODE
      try {
        // 1. Simpan Cloud
        await _supabase.from('cart_items').insert({
          'user_id': _supabase.auth.currentUser!.id,
          'menu_id': item.id, 
          'quantity': 1
        });
        
        // 2. Tarik Ulang (Agar ID Cloud tersimpan & Hive terupdate)
        await _fetchCartFromCloud(); 
        _showSuccessSnackbar(item.name, "Tersimpan di Cloud");

      } catch (e) {
        // JIKA TIBA-TIBA OFFLINE SAAT ADD
        print("⚠️ Offline Fallback");
        cartItems.add(item);
        await cartBox.add(item); // Simpan Lokal
        _showOfflineSnackbar(); 
      }
    } else {
      // GUEST / OFFLINE MODE
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

    // Optimistic Delete (UI)
    if (index < cartItems.length) cartItems.removeAt(index);

    if (isUserLoggedIn) {
      try {
        final cartIdToDelete = cloudCartIds[index];
        if (cartIdToDelete != null) {
          await _supabase.from('cart_items').delete().eq('id', cartIdToDelete);
          await _fetchCartFromCloud(); // Refresh total
        } else {
          // Item offline (belum punya ID), refresh aja
          await _fetchCartFromCloud();
        }
      } catch (e) {
        // Fallback Offline delete
        await cartBox.deleteAt(index);
        _showOfflineSnackbar();
      }
    } else {
      // Guest delete
      await cartBox.deleteAt(index);
    }
  }

  // --- FETCH MENU ---
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

  // --- NOTIFIKASI ---
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