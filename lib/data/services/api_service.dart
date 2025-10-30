import 'api_service_http.dart' as http_service;
import 'api_service_dio.dart' as dio_service;
import '../models/menu_item.dart';

class ApiService {
  static bool useDio = true; // ubah ini untuk beralih mode || true = Dio, false = HTTP

  static Future<List<MenuItem>> fetchMenuItems() async {
    if (useDio) {
      return await dio_service.ApiServiceDio.fetchMenuItems();
    } else {
      return await http_service.ApiServiceHttp.fetchMenuItems();
    }
  }

  // Tambahkan di sini fungsi chaining
  static Future<void> loadAndProcessMenu() async {
    try {
      print('⏳ [CHAINED] Mulai memuat dan memproses data...');

      // ✅ ini otomatis akan pakai yang aktif (Dio / HTTP)
      final items = await fetchMenuItems();
      print('✅ [CHAINED] Data menu berhasil diambil (${items.length} item)');

      final processedItems = items.map((item) {
        final updatedPrice = (item.price * 1.1).toInt();
        return MenuItem(
          item.name,
          '${item.description} (markup)',
          updatedPrice,
          item.icon,
          imageUrl: item.imageUrl,
        );
      }).toList();

      await Future.delayed(const Duration(milliseconds: 500));
      print('💾 [CHAINED] Data sudah diproses & disimpan (simulasi cache)');
      print('🏁 [CHAINED] Selesai.');
    } catch (e) {
      print('❌ [CHAINED] Error: $e');
    }
  }
}
