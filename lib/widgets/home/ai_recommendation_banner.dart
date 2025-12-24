import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../data/controllers/weather_recommendation_controller.dart';
import '../../pages/weather_recommendation_page.dart';

// 🔍 MARKER: AESTHETIC_MINIMALIST_AI_BANNER
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
    
    ever(_controller.recommendation, (_) {
      if (_controller.recommendation.value.isNotEmpty) {
        _buildTexts();
        _startTextRotation();
      }
    });
  }

  // ✅ AESTHETIC: Shorter, more concise texts
  void _buildTexts() {
    _texts.clear();
    final weather = _controller.currentWeather.value;
    
    if (weather != null) {
      final icon = _controller.getWeatherIcon(weather['main_weather']);
      final temp = weather['temperature'].toStringAsFixed(0);
      _texts.add('$icon $temp°C - Lihat rekomendasi menu');
      
      final mainWeather = weather['main_weather'];
      if (mainWeather == 'Rain' || mainWeather == 'Drizzle') {
        _texts.add('🍜 Cuaca hujan, cocok untuk bakso hangat!');
      } else if (mainWeather == 'Clear') {
        _texts.add('☀️ Cerah! Mampir ke Warung Cakwi');
      } else {
        _texts.add('🍜 Menu spesial menanti Anda!');
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Obx(() {
      if (_controller.isLoading.value) {
        return _buildLoadingBanner(colorScheme);
      }

      if (_controller.errorMessage.value.isNotEmpty || _texts.isEmpty) {
        return const SizedBox.shrink();
      }

      // ✅ AESTHETIC: More compact design
      return GestureDetector(
        onTap: () => Get.to(() => const WeatherRecommendationPage()),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // ✅ AESTHETIC: Smaller icon
              Icon(
                Icons.auto_awesome,
                color: colorScheme.onPrimaryContainer,
                size: 18,
              ),
              const SizedBox(width: 10),
              
              // ✅ AESTHETIC: Shorter text
              Expanded(
                child: Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _texts.isNotEmpty ? _texts[_currentTextIndex.value] : '',
                    key: ValueKey(_currentTextIndex.value),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onPrimaryContainer.withOpacity(0.5),
                size: 12,
              ),
            ],
          ),
        ),
      );
    });
  }

  // ✅ AESTHETIC: Simpler loading state
  Widget _buildLoadingBanner(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Memuat rekomendasi...',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
