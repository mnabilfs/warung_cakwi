import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KolosalAIService {
  static final KolosalAIService _instance = KolosalAIService._internal();
  factory KolosalAIService() => _instance;
  KolosalAIService._internal();

  final String _apiKey = dotenv.env['KOLOSAL_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.kolosal.ai/v1';

  /// Generate weather recommendation
  Future<String?> generateWeatherRecommendation({
    required Map<String, dynamic> weatherData,
    required List<Map<String, dynamic>> menuItems,
    DateTime? rainStopTime,
  }) async {
    try {
      // Build prompt untuk AI
      final prompt = _buildPrompt(weatherData, menuItems, rainStopTime);

      final url = Uri.parse('$_baseUrl/chat/completions');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'Claude Sonnet 4.5',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List;
        final message = choices.first['message'] as Map<String, dynamic>;
        return message['content'] as String;
      } else {
        if (kDebugMode) {
          print('❌ Kolosal AI Error: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Kolosal AI Service Error: $e');
      }
      return null;
    }
  }

  String _buildPrompt(
    Map<String, dynamic> weatherData,
    List<Map<String, dynamic>> menuItems,
    DateTime? rainStopTime,
  ) {
    final temp = weatherData['temperature'];
    final feelsLike = weatherData['feels_like'];
    final humidity = weatherData['humidity'];
    final description = weatherData['description'];
    final mainWeather = weatherData['main_weather'];
    final windSpeed = weatherData['wind_speed'];

    // Format menu items
    final menuList =
        menuItems.map((m) => '- ${m['name']}: ${m['description']}').join('\n');

    String rainInfo = '';
    if (mainWeather == 'Rain' || mainWeather == 'Drizzle') {
      if (rainStopTime != null) {
        final hour = rainStopTime.hour;
        final minute = rainStopTime.minute.toString().padLeft(2, '0');
        rainInfo =
            'Hujan diperkirakan reda sekitar pukul $hour:$minute WIB hari ini.';
      } else {
        rainInfo = 'Hujan diperkirakan berlanjut hingga malam atau besok.';
      }
    }

    return '''
Kamu adalah asisten AI untuk Warung Bakso Ojolali Cakwi yang berlokasi di Malang, Jawa Timur.

CUACA SAAT INI (Radius 5KM dari warung):
- Kondisi: $description
- Suhu: ${temp.toStringAsFixed(1)}°C (terasa seperti ${feelsLike.toStringAsFixed(1)}°C)
- Kelembaban: $humidity%
- Kecepatan angin: ${windSpeed.toStringAsFixed(1)} m/s
$rainInfo

MENU YANG TERSEDIA:
$menuList

INSTRUKSI:
1. Berikan informasi cuaca saat ini dengan bahasa yang ramah dan mudah dipahami
2. ${mainWeather == 'Rain' || mainWeather == 'Drizzle' ? 'Informasikan kapan hujan akan reda dan rekomendasikan waktu terbaik untuk berkunjung' : 'Rekomendasikan waktu yang baik untuk berkunjung hari ini'}
3. Rekomendasikan 2-3 menu yang paling cocok dengan cuaca saat ini (misal: jika dingin/hujan → bakso/mie ayam hangat, jika panas → minuman dingin)
4. Berikan alasan singkat kenapa menu tersebut cocok
5. Gunakan emoji yang sesuai untuk membuat lebih menarik
6. Maksimal 200 kata
7. Format dengan paragraf yang jelas dan mudah dibaca
8. Jangan gunakan format markdown seperti **bold** atau #heading

PENTING: Hanya berikan informasi dan rekomendasi, jangan membuat percakapan atau tanya jawab.
''';
  }
}