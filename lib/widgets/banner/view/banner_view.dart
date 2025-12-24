import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/banner_controller.dart';

<<<<<<< HEAD
// 🔍 MARKER: AESTHETIC_MINIMALIST_BANNER
=======
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
class BannerView extends StatefulWidget {
  const BannerView({super.key});

  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  late BannerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(BannerController());
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final colorScheme = Theme.of(context).colorScheme;
    
    // ✅ AESTHETIC: Reduced height & cleaner design
    return Container(
      width: double.infinity,
      height: 120, // Reduced from 200
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest,
            colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: AnimatedBuilder(
        animation: controller.animController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, controller.floatAnimation.value * 0.5), // Subtle float
            child: Row(
              children: [
                // ✅ AESTHETIC: Compact icon
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ),
                
                // ✅ AESTHETIC: Essential text only
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ✅ AESTHETIC: Simple badge
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.badge,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
=======
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2D2D2D), const Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.eco,
              size: 150,
              color: const Color(0xFF8FBC8F).withOpacity(0.1),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Icon(
              Icons.eco,
              size: 120,
              color: const Color(0xFF8FBC8F).withOpacity(0.1),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: controller.animController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, controller.floatAnimation.value),
                  child: Transform.rotate(
                    angle: controller.rotateAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 60,
                          color: Color(0xFFD4A017),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          controller.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4A017),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          controller.subtitle,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A017),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            controller.badge,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
>>>>>>> 0279b523e68f471dbc004169954a430aa50334b0
