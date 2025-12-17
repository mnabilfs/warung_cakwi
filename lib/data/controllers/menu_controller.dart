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

  
  var cloudCartIds = <int, int>{}; 

  final _supabase = Supabase.instance.client;
  
  late Box<MenuItem> menuBox;
  late Box<MenuItem> cartBox;
  late Box settingsBox; 

  @override
  void onInit() async {
    super.onInit();
    
    
    menuBox = await Hive.openBox<MenuItem>('menu_cache');
    cartBox = await Hive.openBox<MenuItem>('cart_cache');
    settingsBox = await Hive.openBox('settings_cache'); 

    
    fetchMenuItems();
    _loadCartFromLocal();

    
    _debugPrintHiveData();

    
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
        
        bool hasOfflineChanges = settingsBox.get('has_offline_changes', defaultValue: false);

        if (hasOfflineChanges) {
          
          
          print("🔄 Mendeteksi perubahan offline. Menimpa Cloud dengan data Lokal...");
          await _forcePushLocalToCloud();
        } else {
          
          
          print("☁️ Tidak ada perubahan offline. Menarik data dari Cloud...");
          await _fetchCartFromCloud();
        }
      }
    }
  }

  
  
  
  Future<void> _forcePushLocalToCloud() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final localItems = cartBox.values.toList();

      
      
      await _supabase.from('cart_items').delete().eq('user_id', userId);

      
      if (localItems.isNotEmpty) {
        for (var item in localItems) {
           await _supabase.from('cart_items').insert({
            'user_id': userId,
            'menu_id': item.id, 
            'quantity': 1
          });
        }
      }

      
      await settingsBox.put('has_offline_changes', false);
      
      
      await _fetchCartFromCloud();

      print("✅ Sukses: Perubahan offline tersimpan ke Cloud.");

    } catch (e) {
      print("⚠️ Gagal Push ke Cloud: $e");
      
    }
  }

  
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
      
      cartItems.assignAll(loadedItems);

      
      await cartBox.clear();
      for (var item in loadedItems) {
        await cartBox.add(item);
      }
      
      
      await settingsBox.put('has_offline_changes', false);

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

  
  void addToCart(MenuItem item) async {
    bool isUserLoggedIn = false;
    if (Get.isRegistered<AuthController>()) {
      isUserLoggedIn = Get.find<AuthController>().isLoggedIn;
    }

    if (isUserLoggedIn) {
      try {
        
        await _supabase.from('cart_items').insert({
          'user_id': _supabase.auth.currentUser!.id,
          'menu_id': item.id, 
          'quantity': 1
        });
        await _fetchCartFromCloud(); 
        _showSuccessSnackbar(item.name, "Tersimpan di Cloud");
      } catch (e) {
        
        cartItems.add(item);
        await cartBox.add(item); 
        await settingsBox.put('has_offline_changes', true); 
        _showOfflineSnackbar(); 
      }
    } else {
      cartItems.add(item);
      await cartBox.add(item);
      _showOfflineSnackbar();
    }

     
     _debugPrintHiveData();
  }

  
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
        await settingsBox.put('has_offline_changes', true); 
        _showOfflineSnackbar();
      }
    } else {
      if (index < cartBox.length) await cartBox.deleteAt(index);
    }
    
    _debugPrintHiveData();
  }
    
    
    void _debugPrintHiveData() {
    print('\n╔═══════════════════════════════════════════════╗');
    print('║           HIVE DATABASE - CART DATA           ║');
    print('╚═══════════════════════════════════════════════╝');
    
    
    print('\n📂 CART BOX (cart_cache):');
    print('   └─ Total Items: ${cartBox.length}');
    print('   └─ Is Empty: ${cartBox.isEmpty}');
    print('   └─ Is Open: ${cartBox.isOpen}');
    
    if (cartBox.isNotEmpty) {
      print('\n   📋 Items di Keranjang:');
      for (int i = 0; i < cartBox.length; i++) {
        final item = cartBox.getAt(i);
        print('   ├─ [$i] ${item?.name}');
        print('   │   ├─ ID: ${item?.id}');
        print('   │   ├─ Harga: Rp ${item?.price}');
        print('   │   └─ Deskripsi: ${item?.description}');
      }
    } else {
      print('   └─ ❌ Keranjang Kosong');
    }
    
    
    print('\n⚙️  SETTINGS BOX (settings_cache):');
    print('   └─ Total Keys: ${settingsBox.length}');
    
    if (settingsBox.isNotEmpty) {
      for (var key in settingsBox.keys) {
        print('   ├─ Key: "$key" → Value: ${settingsBox.get(key)}');
      }
    } else {
      print('   └─ ❌ Tidak ada settings tersimpan');
    }
    
    
    print('\n🔄 OBSERVABLE STATE (GetX):');
    print('   └─ cartItems.length: ${cartItems.length}');
    
    print('\n╚═══════════════════════════════════════════════╝\n');
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
      "Perubahan tersimpan di lokal & akan disinkronkan nanti.",
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