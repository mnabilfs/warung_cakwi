import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'menu_controller.dart';
import '../../pages/landing_page.dart';
import '../../pages/login_page.dart';
import '../models/profile.dart';
import 'package:flutter/foundation.dart';

// 🔍 MARKER: ERROR_PREVENTION_AUTH_LOADING
class AuthController extends GetxController {
  final _supabase = Supabase.instance.client;
  Rx<User?> currentUser = Rx<User?>(null);
  Rx<Profile?> currentProfile = Rx<Profile?>(null);
  
  // ✅ ERROR PREVENTION: Loading State
  var isLoading = false.obs; // TAMBAHKAN INI

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _supabase.auth.currentUser;

    // TAMBAHKAN INI - Load profile saat init
    if (currentUser.value != null) {
      _loadUserProfile();
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;

      // TAMBAHKAN INI - Load profile saat auth change
      if (currentUser.value != null) {
        _loadUserProfile();
      } else {
        currentProfile.value = null;
      }

      if (Get.isRegistered<MenuController>()) {
        Get.find<MenuController>().handleAuthChange();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.value!.id)
          .single();

      currentProfile.value = Profile.fromJson(response);

      if (kDebugMode) {
        print('✅ User role: ${currentProfile.value?.role}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading profile: $e');
      }
    }
  }

  // 🔍 MARKER: ERROR_PREVENTION_LOGIN
Future<void> login(String email, String password) async {
  try {
    // ✅ ERROR PREVENTION: Set Loading State
    isLoading.value = true; // GANTI Get.dialog loading

    await _supabase.auth.signInWithPassword(email: email, password: password);

    // HAPUS Get.back(); // Tidak perlu lagi
    Get.offAll(() => LandingPage());
    Get.snackbar(
      "Berhasil",
      "Selamat datang kembali!",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (e) {
    // ✅ ERROR RECOVERY: Better error message with suggestions
    String errorMsg = e.toString().toLowerCase();
    String title = 'Gagal Login';
    String message = 'Email atau Password salah.';
    
    if (errorMsg.contains('network') || errorMsg.contains('socket')) {
      title = 'Tidak Ada Koneksi';
      message = 'Periksa koneksi internet. Aktifkan WiFi/data.';
    } else if (errorMsg.contains('invalid') || errorMsg.contains('credential')) {
      message = 'Email tidak terdaftar atau password salah.';
    }
    
    Get.snackbar(
      title,
      message,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  } finally {
    // ✅ ERROR PREVENTION: Reset Loading State
    isLoading.value = false; // TAMBAHKAN INI
  }
}

  // 🔍 MARKER: ERROR_PREVENTION_REGISTER
Future<void> register(String email, String password) async {
  try {
    // ✅ ERROR PREVENTION: Set Loading State
    isLoading.value = true; // GANTI Get.dialog loading

    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // HAPUS Get.back(); // Tidak perlu lagi

    if (response.session != null) {
      Get.offAll(() => LandingPage());
      Get.snackbar(
        "Selamat Datang",
        "Akun berhasil dibuat!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Cek Email",
        "Silakan verifikasi email Anda untuk login.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    // HAPUS Get.back(); // Tidak perlu lagi
    Get.snackbar(
      "Gagal Daftar",
      e.toString(),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    // ✅ ERROR PREVENTION: Reset Loading State
    isLoading.value = false; // TAMBAHKAN INI
  }
}

  Future<void> logout() async {
    await _supabase.auth.signOut();

    Get.offAll(() => const LoginPage());
    Get.snackbar(
      "Logout",
      "Sampai jumpa lagi!",
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  bool get isLoggedIn => currentUser.value != null;
  bool get isAdmin => currentProfile.value?.isAdmin ?? false;
  String get userRole => currentProfile.value?.role ?? 'user';
}