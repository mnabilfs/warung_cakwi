import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final authC = Get.find<AuthController>();
  
  
  bool isRegisterMode = false; 

  @override
  Widget build(BuildContext context) {
    
    final goldColor = const Color(0xFFD4A017);
    final darkBg = const Color(0xFF1A1A1A);
    final cardBg = const Color(0xFF2D2D2D);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: goldColor.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: goldColor.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cardBg,
                      boxShadow: [
                        BoxShadow(
                          color: goldColor.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ],
                      border: Border.all(color: goldColor.withOpacity(0.5), width: 2),
                    ),
                    child: Icon(
                      Icons.fastfood_rounded, 
                      size: 60, 
                      color: goldColor
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      isRegisterMode ? "Bergabunglah Bersama Kami" : "Warung Cakwi",
                      key: ValueKey(isRegisterMode),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(color: Colors.black45, offset: Offset(2,2), blurRadius: 4)
                        ]
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRegisterMode ? "Buat akun untuk mulai memesan" : "Masuk untuk melanjutkan pesanan",
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Text(
                          isRegisterMode ? "REGISTER" : "LOGIN",
                          style: TextStyle(
                            color: goldColor, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 2
                          ),
                        ),
                        const SizedBox(height: 20),

                        
                        _buildTextField(
                          controller: emailC,
                          label: "Email Address",
                          icon: Icons.email_outlined,
                          goldColor: goldColor,
                        ),
                        const SizedBox(height: 20),

                        
                        _buildTextField(
                          controller: passC,
                          label: "Password",
                          icon: Icons.lock_outline,
                          goldColor: goldColor,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),

                        
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [goldColor, const Color(0xFFF4C430)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: goldColor.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                if(emailC.text.isEmpty || passC.text.isEmpty){
                                  Get.snackbar("Ups!", "Mohon isi email dan password", 
                                    backgroundColor: Colors.redAccent, colorText: Colors.white);
                                  return;
                                }
                                if (isRegisterMode) {
                                  authC.register(emailC.text, passC.text);
                                  setState(() => isRegisterMode = false); 
                                } else {
                                  authC.login(emailC.text, passC.text);
                                }
                              },
                              child: Text(
                                isRegisterMode ? "DAFTAR SEKARANG" : "MASUK APLIKASI",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isRegisterMode ? "Sudah punya akun?" : "Belum punya akun?",
                        style: const TextStyle(color: Colors.white60),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isRegisterMode = !isRegisterMode;
                            emailC.clear();
                            passC.clear();
                          });
                        },
                        child: Text(
                          isRegisterMode ? "Login Sekarang" : "Daftar Disini",
                          style: TextStyle(
                            color: goldColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  
                  TextButton.icon(
                    onPressed: () => Get.offAllNamed('/home'),
                    icon: const Icon(Icons.offline_bolt, size: 16, color: Colors.grey),
                    label: const Text(
                      "Lanjut tanpa Login (Tamu)",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color goldColor,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: goldColor.withOpacity(0.8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: goldColor),
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}