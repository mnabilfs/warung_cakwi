import 'package:dio/dio.dart';
import '../models/menu_item.dart';

class ApiServiceDio {
  static const String baseUrl =
      'https://warungcakwiapi.a.pinggy.link/api/parfums';
  static final Dio _dio = Dio()
    ..interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: print, // pastikan log tampil di console
      ),
    );

  static Future<List<MenuItem>> fetchMenuItems() async {
    final stopwatch = Stopwatch()..start();

    try {
      print('🚀 Fetching data from: $baseUrl'); // log manual tambahan
      final response = await _dio.get(baseUrl);
      stopwatch.stop(); // berhenti hitung waktu
      print('⏱️ [DIO] Waktu respon: ${stopwatch.elapsedMilliseconds} ms');
      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['data'];

        return items.map((item) {
          return MenuItem(
            item['name'] ?? 'Tanpa Nama',
            item['description'] ?? '',
            (item['price'] as num).toDouble().toInt(),
            null,
            imageUrl: item['image'],
          );
        }).toList();
      } else {
        throw Exception(
          'Gagal memuat data menu (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      stopwatch.stop();
      print('⏱️ [DIO] Gagal setelah ${stopwatch.elapsedMilliseconds} ms');
      print('❌ Error saat fetching: $e');
      throw Exception('Error saat memuat data: $e');
    }
  }
}
