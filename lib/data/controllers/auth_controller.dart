import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'menu_controller.dart';
import '../../pages/landing_page.dart'; 
import '../../pages/login_page.dart'; 

class AuthController extends GetxController {
  final _supabase = Supabase.instance.client;
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;

      if (Get.isRegistered<MenuController>()) {
        Get.find<MenuController>().handleAuthChange();
      }
    });
  }

  
  Future<void> login(String email, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      await _supabase.auth.signInWithPassword(email: email, password: password);
      
      Get.back(); 
      Get.offAll(() => LandingPage()); 
      Get.snackbar("Berhasil", "Selamat datang kembali!", 
        backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.back(); 
      Get.snackbar("Gagal Login", "Email atau Password salah.", 
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  
  Future<void> register(String email, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      
      final response = await _supabase.auth.signUp(email: email, password: password);
      
      Get.back(); 

      if (response.session != null) {
        
        Get.offAll(() => LandingPage()); 
        Get.snackbar("Selamat Datang", "Akun berhasil dibuat!", 
          backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        
        Get.snackbar("Cek Email", "Silakan verifikasi email Anda untuk login.", 
          backgroundColor: Colors.orange, colorText: Colors.white);
      }

    } catch (e) {
      Get.back();
      Get.snackbar("Gagal Daftar", e.toString(), 
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  
  Future<void> logout() async {
    await _supabase.auth.signOut();
    
    Get.offAll(() => const LoginPage());
    Get.snackbar("Logout", "Sampai jumpa lagi!",
       backgroundColor: Colors.blue, colorText: Colors.white);
  }

  bool get isLoggedIn => currentUser.value != null;
}