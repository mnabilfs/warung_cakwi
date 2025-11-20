import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  // Key yang akan digunakan untuk menyimpan di SharedPreferences
  static const String _themeKey = 'isDarkTheme';

  // Observable untuk menyimpan status tema saat ini
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Muat tema yang tersimpan setiap kali controller diinisialisasi
    _loadTheme();
  }

  // Memuat status tema dari penyimpanan lokal
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Jika tidak ada data tersimpan, default-nya adalah false (Light Mode)
    final savedTheme = prefs.getBool(_themeKey) ?? false;
    isDarkMode.value = savedTheme;
    // Set tema aplikasi secara global saat dimuat
    Get.changeThemeMode(savedTheme ? ThemeMode.dark : ThemeMode.light);

        // Cetak Data SharedPreferences untuk debugging
        _printSharedPrefs(prefs);
  }
  // Mengubah status tema dan menyimpannya
  void toggleTheme() async {
    // Balik nilai saat ini
    isDarkMode.value = !isDarkMode.value;

    // Terapkan perubahan tema ke GetMaterialApp
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // Simpan nilai baru ke SharedPreferences (Data Persisten)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode.value);

    // Cetak data SharedPrefences untuk debugging
    _printSharedPrefs(prefs);

    // Snackbar pemberitahuan
    Get.snackbar(
      'Tema Berhasil Diubah',
      isDarkMode.value ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Fungsi untuk mencetak semua data di SharedPreferences
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
