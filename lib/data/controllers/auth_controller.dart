import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'menu_controller.dart';
import '../../pages/landing_page.dart'; 
import '../../pages/login_page.dart'; // Import Login Page untuk Logout

class AuthController extends GetxController {
  final _supabase = Supabase.instance.client;
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // 1. Cek user saat controller pertama kali dibuat
    currentUser.value = _supabase.auth.currentUser;

    // 2. Pasang pendengar (Listener)
    // Ini otomatis jalan jika user login/logout/register
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      
      // Update keranjang jika ada MenuController
      if (Get.isRegistered<MenuController>()) {
        Get.find<MenuController>().handleAuthChange();
      }
    });
  }

  // --- FUNGSI LOGIN ---
  Future<void> login(String email, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      await _supabase.auth.signInWithPassword(email: email, password: password);
      
      Get.back(); // Tutup loading
      Get.offAll(() => LandingPage()); // Pindah ke Menu Utama
      Get.snackbar("Berhasil", "Selamat datang kembali!", 
        backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.back(); 
      Get.snackbar("Gagal Login", "Email atau Password salah.", 
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- FUNGSI DAFTAR (REGISTER) ---
  Future<void> register(String email, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      // Supabase otomatis meloginkan user setelah sign up (jika confirm email dimatikan)
      final response = await _supabase.auth.signUp(email: email, password: password);
      
      Get.back(); // Tutup loading

      if (response.session != null) {
        // 🔴 SUKSES: Langsung masuk ke Menu Utama (LandingPage)
        Get.offAll(() => LandingPage()); 
        Get.snackbar("Selamat Datang", "Akun berhasil dibuat!", 
          backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // Jika Supabase Anda mewajibkan verifikasi email
        Get.snackbar("Cek Email", "Silakan verifikasi email Anda untuk login.", 
          backgroundColor: Colors.orange, colorText: Colors.white);
      }

    } catch (e) {
      Get.back();
      Get.snackbar("Gagal Daftar", e.toString(), 
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logout() async {
    await _supabase.auth.signOut();
    // Kembali ke Halaman Login dan hapus semua history halaman sebelumnya
    Get.offAll(() => const LoginPage());
    Get.snackbar("Logout", "Sampai jumpa lagi!",
       backgroundColor: Colors.blue, colorText: Colors.white);
  }

  bool get isLoggedIn => currentUser.value != null;
}