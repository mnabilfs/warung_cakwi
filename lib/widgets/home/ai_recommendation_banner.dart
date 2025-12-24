import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../data/controllers/weather_recommendation_controller.dart';
import '../../pages/weather_recommendation_page.dart';

class AIRecommendationBanner extends StatefulWidget {
  const AIRecommendationBanner({super.key});

  @override
  State<AIRecommendationBanner> createState() => _AIRecommendationBannerState();
}

class _AIRecommendationBannerState extends State<AIRecommendationBanner> {
  late WeatherRecommendationController _controller;
  Timer? _rotationTimer;
  final RxInt _currentTextIndex = 0.obs;
  final List<String> _texts = [];

  @override
  void initState() {
    super.initState();
    _controller = Get.put(WeatherRecommendationController());
    
    // Start text rotation setelah data loaded
    ever(_controller.recommendation, (_) {
      if (_controller.recommendation.value.isNotEmpty) {
        _buildTexts();
        _startTextRotation();
      }
    });
  }

  void _buildTexts() {
    _texts.clear();
    final weather = _controller.currentWeather.value;
    
    if (weather != null) {
      // Text 1: Info cuaca
      final icon = _controller.getWeatherIcon(weather['main_weather']);
      final temp = weather['temperature'].toStringAsFixed(0);
      final desc = weather['description'];
      _texts.add('$icon Cuaca sekarang: $temp°C, $desc');
      
      // Text 2: Status hujan
      final mainWeather = weather['main_weather'];
      if (mainWeather == 'Rain' || mainWeather == 'Drizzle') {
        _texts.add('🌧️ Sedang hujan! Cocok untuk makan hangat di warung');
      } else if (mainWeather == 'Clear') {
        _texts.add('☀️ Cerah! Waktu yang tepat untuk mampir ke warung');
      } else {
        _texts.add('🌤️ Cuaca mendukung untuk berkunjung!');
      }
      
      // Text 3: Rekomendasi menu singkat
      final recommendation = _controller.recommendation.value;
      final menuMatch = RegExp(r'(?:bakso|mie ayam|minuman)', caseSensitive: false)
          .allMatches(recommendation.toLowerCase());
      
      if (menuMatch.isNotEmpty) {
        final menus = menuMatch.map((m) => m.group(0)).toSet().take(2).join(' & ');
        _texts.add('🍜 Rekomendasi AI: $menus pas untuk cuaca ini!');
      } else {
        _texts.add('🍜 AI merekomendasikan menu spesial untuk Anda!');
      }
    }
  }

  void _startTextRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_texts.isNotEmpty) {
        _currentTextIndex.value = (_currentTextIndex.value + 1) % _texts.length;
      }
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading state
      if (_controller.isLoading.value) {
        return _buildLoadingBanner();
      }

      // Error state
      if (_controller.errorMessage.value.isNotEmpty) {
        return const SizedBox.shrink(); // Hide banner if error
      }

      // Success state
      if (_texts.isEmpty) {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onTap: () {
          Get.to(() => const WeatherRecommendationPage());
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD4A017).withOpacity(0.9),
                const Color(0xFFF4C430).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A017).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // AI Icon with pulse animation
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Rotating text
              Expanded(
                child: Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _texts.isNotEmpty ? _texts[_currentTextIndex.value] : '',
                    key: ValueKey(_currentTextIndex.value),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
              ),
              
              const SizedBox(width: 8),
              
              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black54,
                size: 16,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLoadingBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFD4A017),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'AI sedang menganalisis cuaca & menu...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}