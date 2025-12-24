import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/weather_service.dart';
import '../services/kolosal_ai_service.dart';
import 'menu_controller.dart' as my;

class WeatherRecommendationController extends GetxController {
  final WeatherService _weatherService = WeatherService();
  final KolosalAIService _aiService = KolosalAIService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString recommendation = ''.obs;
  final Rx<Map<String, dynamic>?> currentWeather = Rx<Map<String, dynamic>?>(null);
  final RxBool isAutoRefreshing = false.obs;
  final RxInt refreshAttempt = 0.obs;
  final RxInt lastRecommendationLength = 0.obs;

  Timer? _autoRefreshTimer;
  static const int MAX_REFRESH_ATTEMPTS = 10; // Maksimal 10x percobaan
  static const Duration REFRESH_INTERVAL = Duration(seconds: 5); // Refresh setiap 5 detik

  @override
  void onInit() {
    super.onInit();
    startAutoRefresh();
  }

  @override
  void onClose() {
    stopAutoRefresh();
    super.onClose();
  }

  /// Mulai auto-refresh terus menerus
  void startAutoRefresh() {
    if (isAutoRefreshing.value) return;
    
    isAutoRefreshing.value = true;
    refreshAttempt.value = 0;
    
    if (kDebugMode) {
      print('🔄 Starting auto-refresh for AI recommendations...');
    }
    
    // Generate pertama kali
    _generateWithRetry();
    
    // Set timer untuk refresh berulang
    _autoRefreshTimer = Timer.periodic(REFRESH_INTERVAL, (timer) {
      if (refreshAttempt.value >= MAX_REFRESH_ATTEMPTS) {
        if (kDebugMode) {
          print('⏹️ Max refresh attempts reached (${MAX_REFRESH_ATTEMPTS})');
        }
        stopAutoRefresh();
        return;
      }
      
      if (recommendation.value.isNotEmpty && recommendation.value.length > lastRecommendationLength.value) {
        if (kDebugMode) {
          print('✅ Recommendation length improved: ${lastRecommendationLength.value} -> ${recommendation.value.length}');
        }
        lastRecommendationLength.value = recommendation.value.length;
      }
      
      _generateWithRetry();
    });
  }

  /// Hentikan auto-refresh
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    isAutoRefreshing.value = false;
    
    if (kDebugMode) {
      print('🛑 Auto-refresh stopped');
    }
  }

  /// Restart auto-refresh
  void restartAutoRefresh() {
    stopAutoRefresh();
    startAutoRefresh();
  }

  /// Generate dengan retry logic
  Future<void> _generateWithRetry() async {
    if (isLoading.value) return;
    
    refreshAttempt.value++;
    
    if (kDebugMode) {
      print('🔄 Attempt #${refreshAttempt.value} to generate recommendation...');
    }
    
    await generateRecommendation();
  }

  Future<void> generateRecommendation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // 1. Get current weather
      if (kDebugMode) print('🌤️ Fetching weather data...');
      final weatherData = await _weatherService.getCurrentWeather();

      if (weatherData == null) {
        throw Exception('Gagal mengambil data cuaca');
      }

      final parsedWeather = _weatherService.parseWeatherData(weatherData);
      currentWeather.value = parsedWeather;

      // 2. Check if raining, get forecast for when it stops
      DateTime? rainStopTime;
      if (parsedWeather['main_weather'] == 'Rain' ||
          parsedWeather['main_weather'] == 'Drizzle') {
        if (kDebugMode) print('🌧️ Raining, checking forecast...');
        final forecast = await _weatherService.getWeatherForecast();
        if (forecast != null) {
          rainStopTime = _weatherService.findWhenRainStops(forecast);
        }
      }

      // 3. Get menu items from MenuController
      List<Map<String, dynamic>> menuItems = [];
      if (Get.isRegistered<my.MenuController>()) {
        final menuController = Get.find<my.MenuController>();
        menuItems = menuController.menuItems.map((item) {
          return {
            'name': item.name,
            'description': item.description,
            'price': item.price,
          };
        }).toList();
      }

      if (menuItems.isEmpty) {
        throw Exception('Tidak ada data menu tersedia');
      }

      // 4. Generate AI recommendation
      if (kDebugMode) print('🤖 Generating AI recommendation...');
      final aiResponse = await _aiService.generateWeatherRecommendation(
        weatherData: parsedWeather,
        menuItems: menuItems,
        rainStopTime: rainStopTime,
      );

      if (aiResponse == null) {
        throw Exception('Gagal menghasilkan rekomendasi AI');
      }

      recommendation.value = aiResponse;
      
      // Simpan panjang terakhir untuk tracking improvement
      lastRecommendationLength.value = aiResponse.length;

      if (kDebugMode) {
        print('✅ Recommendation generated successfully (${aiResponse.length} chars)');
        print('📊 Refresh attempt: ${refreshAttempt.value}');
      }
      
      // Jika sudah mendapatkan rekomendasi yang cukup panjang, stop refresh
      if (aiResponse.length > 50 && refreshAttempt.value > 2) {
        if (kDebugMode) {
          print('🎉 Got good recommendation, stopping auto-refresh');
        }
        stopAutoRefresh();
      }
      
    } catch (e, stackTrace) {
      errorMessage.value = e.toString();
      if (kDebugMode) {
        print('❌ Error generating recommendation: $e');
        print('Stack trace: $stackTrace');
      }
      
      // Coba lagi di iterasi berikutnya
      if (refreshAttempt.value >= MAX_REFRESH_ATTEMPTS) {
        errorMessage.value = 'Gagal mendapatkan rekomendasi setelah ${MAX_REFRESH_ATTEMPTS} percobaan. Silakan refresh manual.';
        stopAutoRefresh();
      }
    } finally {
      isLoading.value = false;
    }
  }

  String getWeatherIcon(String? mainWeather) {
    switch (mainWeather) {
      case 'Clear':
        return '☀️';
      case 'Clouds':
        return '☁️';
      case 'Rain':
        return '🌧️';
      case 'Drizzle':
        return '🌦️';
      case 'Thunderstorm':
        return '⛈️';
      case 'Snow':
        return '❄️';
      case 'Mist':
      case 'Fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  List<String> extractRecommendedMenus() {
    final text = recommendation.value.toLowerCase();
    final menuKeywords = ['bakso', 'mie ayam', 'minuman', 'es teh', 'es jeruk'];
    
    List<String> found = [];
    for (var keyword in menuKeywords) {
      if (text.contains(keyword)) {
        found.add(keyword);
      }
    }
    
    return found.take(2).toList();
  }

  /// Check if we have a valid recommendation
  bool get hasValidRecommendation => recommendation.value.isNotEmpty && recommendation.value.length > 20;
}