import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';

class ApiServiceHttp {
  static const String baseUrl =
      'https://warungcakwiapi.a.pinggy.link/api/parfums';

  static Future<List<MenuItem>> fetchMenuItems() async {
    final stopwatch = Stopwatch()..start();
    final response = await http.get(Uri.parse(baseUrl));

    stopwatch.stop(); // ⏱️ berhenti setelah request selesai
    print('⏱️ [HTTP] Waktu respon: ${stopwatch.elapsedMilliseconds} ms');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['data'];

      return items.map((item) {
        return MenuItem(
          item['name'],
          item['description'],
          item['price'].toDouble().toInt(),
          null, // kalau pakai icon, nanti bisa diatur
          imageUrl: item['image'], // tambahkan properti baru ke model
        );
      }).toList();
    } else {
      throw Exception('Gagal memuat data menu');
    }
  }
}
