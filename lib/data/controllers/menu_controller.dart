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
  // Map ID Cloud untuk penghapusan
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

    // 2. Load Menu
    fetchMenuItems();

    // 3. Cek Login & Lakukan Sinkronisasi Cerdas
    Future.delayed(const Duration(milliseconds: 500), () {
       _smartSync();
    });
  }

  // --- LOGIKA SINKRONISASI CERDAS (SMART SYNC) ---
  void _smartSync() async {
    // Tampilkan data lokal dulu biar user tidak menunggu
    _loadCartFromLocal();

    if (Get.isRegistered<AuthController>()) {
      final authC = Get.find<AuthController>();
      
      if (authC.isLoggedIn) {
        // STEP 1: SYNC UP (Lokal -> Cloud)
        // Jika user punya data lokal (hasil offline) tapi cloud kosong/beda,
        // kita coba upload data lokal ke cloud dulu.
        if (cartBox.isNotEmpty) {
          await _uploadLocalToCloud();
        }

        // STEP 2: SYNC DOWN (Cloud -> Lokal)
        // Ambil data terbaru dari cloud untuk memastikan sinkronisasi total
        await _fetchCartFromCloud();
      } else {
        // Jika Guest: Tampilkan Snackbar Offline saat awal buka
        if (cartBox.isNotEmpty) {
           _showOfflineSnackbar();
        }
      }
    }
  }

  // Fungsi Upload data Offline ke Online (Sync Up)
  Future<void> _uploadLocalToCloud() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      print("🔄 Mencoba upload data Offline ke Cloud...");

      // Ambil semua item di lokal
      final localItems = cartBox.values.toList();

      // Kita hapus dulu data di Cloud (Strategy: Replace) agar tidak duplikat
      // Atau jika ingin append, hapus baris delete di bawah ini.
      // Tapi untuk cart sederhana, Replace biasanya lebih aman agar sinkron.
      await _supabase.from('cart_items').delete().eq('user_id', userId);

      // Upload ulang semua item lokal ke Cloud
      for (var item in localItems) {
        await _supabase.from('cart_items').insert({
          'user_id': userId,
          'menu_id': item.id,
          'quantity': 1
        });
      }
      print("✅ Sukses Upload Data Offline ke Cloud");
    } catch (e) {
      print("⚠️ Gagal Upload (Mungkin masih offline): $e");
    }
  }

  // --- FUNGSI LOAD & SAVE LOKAL ---

  void _loadCartFromLocal() {
    if (cartBox.isNotEmpty) {
      cartItems.assignAll(cartBox.values.toList());
    } else {
      cartItems.clear();
    }
  }

  Future<void> _syncCartToLocal(List<MenuItem> items) async {
    await cartBox.clear();
    for (var item in items) {
      await cartBox.add(item);
    }
  }

  // --- FUNGSI AMBIL DARI CLOUD (SYNC DOWN) ---

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
      
      // Update UI & Backup ke Hive
      cartItems.assignAll(loadedItems);
      await _syncCartToLocal(loadedItems); 

    } catch (e) {
      print("⚠️ Gagal ambil Cloud (Mode Offline aktif)");
      _loadCartFromLocal(); // Fallback ke data lokal
      _showOfflineSnackbar(); // Tampilkan Notif
    }
  }

  // --- TAMBAH KE KERANJANG (MODIFIKASI OFFLINE) ---

  @override
  void addToCart(MenuItem item) async {
    bool isUserLoggedIn = false;
    if (Get.isRegistered<AuthController>()) {
      isUserLoggedIn = Get.find<AuthController>().isLoggedIn;
    }

    // 1. Simpan Lokal Dulu (Wajib)
    cartItems.add(item); // Update UI
    await cartBox.add(item); // Simpan Hive

    // 2. Coba Simpan Cloud
    if (isUserLoggedIn) {
      try {
        await _supabase.from('cart_items').insert({
          'user_id': _supabase.auth.currentUser!.id,
          'menu_id': item.id, 
          'quantity': 1
        });
        // Refresh ID mapping
        _fetchCartFromCloud();
        
        // Notif Sukses Online
        _showSuccessSnackbar(item.name, "Tersimpan di Cloud");

      } catch (e) {
        // 🔴 JIKA INTERNET MATI / GAGAL
        print("⚠️ Gagal ke Cloud: $e");
        _showOfflineSnackbar(); // Tampilkan Notif Offline yang diminta
      }
    } else {
      // Jika Guest
      _showOfflineSnackbar();
    }
  }

  // --- HAPUS DARI KERANJANG ---

  void removeFromCart(int index) async {
     bool isUserLoggedIn = false;
    if (Get.isRegistered<AuthController>()) {
      isUserLoggedIn = Get.find<AuthController>().isLoggedIn;
    }

    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
      await cartBox.deleteAt(index);

      if (isUserLoggedIn) {
        try {
          final cartIdToDelete = cloudCartIds[index];
          if (cartIdToDelete != null) {
            await _supabase.from('cart_items').delete().eq('id', cartIdToDelete);
            _fetchCartFromCloud(); 
          } else {
            // Kalau ID null (item offline), sync ulang aja
            await _uploadLocalToCloud();
            await _fetchCartFromCloud();
          }
        } catch (e) {
           _showOfflineSnackbar();
        }
      }
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
    } catch (e) {
      final localData = menuBox.values.toList();
      if (localData.isNotEmpty) menuItems.assignAll(localData);
    } finally {
      isLoading.value = false;
    }
  }
  
  // --- SNACKBAR KHUSUS (YANG ANDA MINTA) ---
  
  void _showOfflineSnackbar() {
    if (Get.isSnackbarOpen) return; // Cegah spam notif
    
    Get.snackbar(
      "Mode Offline",
      "Data tersimpan di local storage",
      icon: const Icon(Icons.wifi_off, color: Colors.white),
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP, // Muncul di Atas
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

  void _showSuccessSnackbar(String itemName, String subtitle) {
    Get.snackbar(
      "Berhasil",
      "$itemName - $subtitle",
      icon: const Icon(Icons.cloud_done, color: Colors.white),
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }
  
  // Panggil ini dari AuthController saat login/logout
  void handleAuthChange() {
    _smartSync();
  }
}