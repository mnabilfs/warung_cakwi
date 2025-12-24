import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  final String _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Koordinat Warung Cakwi
  static const double warungLat = -7.901906;
  static const double warungLon = 112.582788;

  /// Get current weather di lokasi warung
  Future<Map<String, dynamic>?> getCurrentWeather() async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$warungLat&lon=$warungLon&appid=$_apiKey&units=metric&lang=id',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print('❌ Weather API Error: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Weather Service Error: $e');
      }
      return null;
    }
  }

  /// Get weather forecast (3-hour intervals untuk 5 hari)
  Future<Map<String, dynamic>?> getWeatherForecast() async {
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?lat=$warungLat&lon=$warungLon&appid=$_apiKey&units=metric&lang=id',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print('❌ Forecast API Error: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Forecast Service Error: $e');
      }
      return null;
    }
  }

  /// Parse weather data untuk mendapatkan info penting
  Map<String, dynamic> parseWeatherData(Map<String, dynamic> data) {
    final main = data['main'] as Map<String, dynamic>;
    final weather = (data['weather'] as List).first as Map<String, dynamic>;
    final wind = data['wind'] as Map<String, dynamic>;
    final clouds = data['clouds'] as Map<String, dynamic>;

    return {
      'temperature': main['temp'],
      'feels_like': main['feels_like'],
      'humidity': main['humidity'],
      'pressure': main['pressure'],
      'description': weather['description'],
      'main_weather': weather['main'], // Rain, Clear, Clouds, dll
      'icon': weather['icon'],
      'wind_speed': wind['speed'],
      'cloudiness': clouds['all'],
      'timestamp': DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000),
    };
  }

  /// Cari kapan hujan akan reda (dari forecast)
  DateTime? findWhenRainStops(Map<String, dynamic> forecastData) {
    final list = forecastData['list'] as List;

    for (var item in list) {
      final weather =
          (item['weather'] as List).first as Map<String, dynamic>;
      final mainWeather = weather['main'] as String;
      final dt = item['dt'] as int;

      // Jika bukan hujan, return waktu tersebut
      if (mainWeather != 'Rain' && mainWeather != 'Drizzle') {
        return DateTime.fromMillisecondsSinceEpoch(dt * 1000);
      }
    }

    return null; // Hujan terus dalam 5 hari ke depan (unlikely)
  }
}