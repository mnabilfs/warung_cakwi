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

  // Map untuk menyimpan ID cart Cloud (agar bisa dihapus di Supabase)
  // Key: Index di List UI, Value: ID Database Supabase
  var cloudCartIds = <int, int>{}; 

  final _supabase = Supabase.instance.client;
  late Box<MenuItem> menuBox;
  late Box<MenuItem> cartBox;

  @override
  void onInit() async {
    super.onInit();
    // Buka Database Lokal
    menuBox = await Hive.openBox<MenuItem>('menu_cache');
    cartBox = await Hive.openBox<MenuItem>('cart_cache');

    fetchMenuItems();

    // Tunggu sebentar agar AuthController siap, lalu cek keranjang
    Future.delayed(const Duration(milliseconds: 500), () {
       _checkAuthAndLoadCart();
    });
  }

  void _checkAuthAndLoadCart() {
    // Selalu load lokal dulu agar user langsung lihat keranjangnya (Anti-Kedip)
    _loadCartFromLocal();

    if (Get.isRegistered<AuthController>()) {
      final authC = Get.find<AuthController>();
      if (authC.isLoggedIn) {
        // Jika Online/Login, baru coba update dari Cloud
        _fetchCartFromCloud(); 
      }
    }
  }

  void handleAuthChange() {
    _checkAuthAndLoadCart();
  }

  // --- FUNGSI LOKAL (HIVE - STABIL) ---

  void _loadCartFromLocal() {
    if (cartBox.isNotEmpty) {
      // Konversi values Hive langsung ke List agar urutannya sama persis
      cartItems.assignAll(cartBox.values.toList());
      print("📦 Load Cart dari HIVE (Lokal) - Jumlah: ${cartItems.length}");
    } else {
      cartItems.clear();
    }
  }

  // Simpan cadangan Cloud ke Hive (Sync Down)
  Future<void> _syncCartToLocal(List<MenuItem> items) async {
    await cartBox.clear(); 
    // Gunakan .add() agar Hive mengatur urutan index secara otomatis
    for (var item in items) {
      await cartBox.add(item);
    }
    print("💾 Cart berhasil dicadangkan ke Hive (Offline Ready)");
  }

  // --- FUNGSI CLOUD (SUPABASE) ---
  
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
          // Simpan ID cart Cloud untuk penghapusan nanti
          cloudCartIds[i] = itemData['id']; 
        }
      }
      
      // 1. Update Tampilan
      cartItems.assignAll(loadedItems);

      // 2. Update Cadangan Lokal
      await _syncCartToLocal(loadedItems);

    } catch (e) {
      print("⚠️ Gagal koneksi Cloud: $e");
      // Jangan lakukan apa-apa jika gagal, biarkan data lokal (Hive) yang tampil
      // Ini mencegah data lokal hilang saat internet mati nyala
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
      if (localData.isNotEmpty) {
        menuItems.assignAll(localData);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- ADD TO CART (PERBAIKAN LOGIC) ---

  @override
  void addToCart(MenuItem item) async {
    bool isUserLoggedIn = false;
    if (Get.isRegistered<AuthController>()) {
      isUserLoggedIn = Get.find<AuthController>().isLoggedIn;
    }

    // 1. Update Tampilan Langsung (Biar Cepat)
    cartItems.add(item);
    _showCustomSnackbar(item); 

    // 2. Simpan ke Hive (Wajib, sebagai single source of truth saat offline)
    // Kita gunakan .add() agar indexnya sinkron dengan List cartItems
    await cartBox.add(item);

    // 3. Jika Login, Coba Kirim ke Cloud
    if (isUserLoggedIn) {
      try {
        await _supabase.from('cart_items').insert({
          'user_id': _supabase.auth.currentUser!.id,
          'menu_id': item.id, 
          'quantity': 1
        });
        
        // Refresh Cloud ID mapping tanpa mereset tampilan kasar
        _fetchCartFromCloud(); 

      } catch (e) {
        print("⚠️ Offline: Item tersimpan di Hive, tapi gagal ke Cloud.");
        // Tidak perlu fallback manual lagi karena di langkah 2 sudah kita simpan ke Hive
      }
    }
  }

  // --- REMOVE FROM CART (PERBAIKAN LOGIC) ---

  void removeFromCart(int index) async {
     bool isUserLoggedIn = false;
    if (Get.isRegistered<AuthController>()) {
      isUserLoggedIn = Get.find<AuthController>().isLoggedIn;
    }

    if (index >= 0 && index < cartItems.length) {
      // 1. Hapus dari Tampilan
      cartItems.removeAt(index);

      // 2. Hapus dari Hive (Gunakan deleteAt agar sinkron dengan index List)
      await cartBox.deleteAt(index);

      // 3. Hapus dari Cloud (Jika Login)
      if (isUserLoggedIn) {
        try {
          // Ambil ID Cloud berdasarkan index
          // Kita gunakan index yang aman karena hive & list sudah sinkron
          final cartIdToDelete = cloudCartIds[index];
          
          if (cartIdToDelete != null) {
            await _supabase.from('cart_items').delete().eq('id', cartIdToDelete);
            
            // Refresh mapping, tapi jangan reset cartItems drastis
            _fetchCartFromCloud(); 
          }
        } catch (e) {
          print("Gagal hapus cloud: $e");
          // Data lokal sudah terhapus, jadi secara UX user tidak terganggu
        }
      }
    }
  }

  void _showCustomSnackbar(MenuItem item) {
    Get.snackbar(
      '', '',
      titleText: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.check_circle_outline, color: Color(0xFFD4A017), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Ditambahkan ke Keranjang', style: TextStyle(color: Color(0xFFD4A017), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(item.name, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
        ],
      ),
      messageText: const SizedBox.shrink(),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF2D2D2D),
      borderRadius: 12,
      margin: const EdgeInsets.only(top: 10, left: 12, right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderColor: const Color(0xFFD4A017).withOpacity(0.3),
      borderWidth: 1,
      duration: const Duration(milliseconds: 1500),
    );
  }
}