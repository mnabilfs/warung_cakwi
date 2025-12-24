import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
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

  @override
  void onInit() {
    super.onInit();
    generateRecommendation();
  }

  Future<void> generateRecommendation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      recommendation.value = '';

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

      if (kDebugMode) {
        print('✅ Recommendation generated successfully');
      }
    } catch (e, stackTrace) {
      errorMessage.value = e.toString();
      if (kDebugMode) {
        print('❌ Error generating recommendation: $e');
        print('Stack trace: $stackTrace');
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
    
    return found.take(2).toList(); // Max 2 menus
  }
}