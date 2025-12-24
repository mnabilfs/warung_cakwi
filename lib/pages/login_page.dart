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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Decorative circle - top right
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          // Decorative circle - bottom left
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.secondary.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surfaceContainerHighest,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ],
                      border: Border.all(color: colorScheme.primary.withOpacity(0.5), width: 2),
                    ),
                    child: Icon(
                      Icons.fastfood_rounded, 
                      size: 60, 
                      color: colorScheme.primary
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title with animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      isRegisterMode ? "Bergabunglah Bersama Kami" : "Warung Cakwi",
                      key: ValueKey(isRegisterMode),
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(color: Colors.black45, offset: const Offset(2,2), blurRadius: 4)
                        ]
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRegisterMode ? "Buat akun untuk mulai memesan" : "Masuk untuk melanjutkan pesanan",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login/Register Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form title
                        Text(
                          isRegisterMode ? "REGISTER" : "LOGIN",
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 2
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email field
                        _buildTextField(
                          context: context,
                          controller: emailC,
                          label: "Email Address",
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 20),

                        // Password field
                        _buildTextField(
                          context: context,
                          controller: passC,
                          label: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),

                        // Submit button with gradient
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [colorScheme.primary, colorScheme.primaryContainer],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.4),
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
                                    backgroundColor: colorScheme.error, colorText: colorScheme.onError);
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
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
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

                  // Toggle login/register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isRegisterMode ? "Sudah punya akun?" : "Belum punya akun?",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
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
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Guest login
                  TextButton.icon(
                    onPressed: () => Get.offAllNamed('/home'),
                    icon: Icon(Icons.offline_bolt, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
                    label: Text(
                      "Lanjut tanpa Login (Tamu)",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
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
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary.withOpacity(0.8)),
      ),
    );
  }
}