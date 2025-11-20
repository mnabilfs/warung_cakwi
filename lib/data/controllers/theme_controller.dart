import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  
  static const String _themeKey = 'isDarkTheme';

  
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    _loadTheme();
  }

  
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    final savedTheme = prefs.getBool(_themeKey) ?? false;
    isDarkMode.value = savedTheme;
    
    Get.changeThemeMode(savedTheme ? ThemeMode.dark : ThemeMode.light);

        
        _printSharedPrefs(prefs);
  }
  
  void toggleTheme() async {
    
    isDarkMode.value = !isDarkMode.value;

    
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode.value);

    
    _printSharedPrefs(prefs);

    
    Get.snackbar(
      'Tema Berhasil Diubah',
      isDarkMode.value ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  
   void _printSharedPrefs(SharedPreferences prefs) {
    print('SHARED PREFERENCES - DATA TEMA');

    Set<String> keys = prefs.getKeys();
    
    if (keys.isEmpty) {
      print('❌ Tidak ada data tersimpan');
    } else {
      print('📁 Total Keys: ${keys.length}');
      print('───────────────────────────────────────');
      for (String key in keys) {
        dynamic value = prefs.get(key);
        print('🔑 $key = $value (${value.runtimeType})');
      }
    }
    print('═══════════════════════════════════════\n');
  }
}
