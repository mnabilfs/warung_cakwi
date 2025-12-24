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
    
    // Mulai auto-refresh jika belum
    if (!_controller.isAutoRefreshing.value) {
      _controller.startAutoRefresh();
    }
    
    // Jika sudah ada rekomendasi, langsung buat teks
    if (_controller.recommendation.value.isNotEmpty) {
      _buildTexts();
      _startTextRotation();
    }
    
    // Listen untuk perubahan rekomendasi
    ever(_controller.recommendation, (_) {
      if (_controller.recommendation.value.isNotEmpty) {
        _buildTexts();
        _startTextRotation();
      }
    });
  }

  void _buildTexts() {
    _texts.clear();
    
    // 1. Sambutan
    _texts.add('Selamat datang di Warung Cakwi!');
    
    // 2. Cuaca Hari Ini
    final weather = _controller.currentWeather.value;
    if (weather != null) {
      final temp = weather['temperature'].toStringAsFixed(0);
      final condition = weather['description'];
      final icon = _controller.getWeatherIcon(weather['main_weather']);
      _texts.add('$icon Cuaca: $temp°C, $condition');
    }
    
    // 3. Menu Rekomendasi
    final recommendedMenus = _controller.extractRecommendedMenus();
    if (recommendedMenus.isNotEmpty) {
      _texts.add('🍜 Rekomendasi Menu: ${recommendedMenus.join(', ')}');
    } else {
      _texts.add('🍜 RekomendasiMenu: Tidak Bisa Memunculkan Rekomendasi');
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
              Icon(
                Icons.auto_awesome,
                color: colorScheme.onPrimaryContainer,
                size: 18,
              ),
              const SizedBox(width: 10),
              
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