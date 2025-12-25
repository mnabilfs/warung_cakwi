// lib/data/controllers/order_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../models/menu_item.dart';
import '../services/fcm_service.dart';

class OrderController extends GetxController {
  final _supabase = Supabase.instance.client;
  final FcmService _fcmService = FcmService();

  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  /// Fetch orders (user: own orders, admin: all orders)
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);

      final List<OrderModel> data = (response as List<dynamic>)
          .map((item) => OrderModel.fromJson(item))
          .toList();

      orders.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
      if (kDebugMode) print('❌ Fetch orders error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create new order from cart items
  Future<bool> createOrder({
    required List<MenuItem> cartItems,
    required int totalPrice,
    required String paymentMethod,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User tidak login');
      }

      // 1. Insert order
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'user_email': user.email ?? 'Unknown',
            'total_price': totalPrice,
            'payment_method': paymentMethod,
            'status': 'pending',
          })
          .select()
          .single();

      final orderId = orderResponse['id'] as int;

      // 2. Insert order items
      final orderItems = cartItems.map((item) {
        return {
          'order_id': orderId,
          'menu_id': item.id,
          'menu_name': item.name,
          'menu_price': item.price,
          'quantity': 1,
        };
      }).toList();

      await _supabase.from('order_items').insert(orderItems);

      // 3. Send notification to admin
      await _fcmService.sendMenuUpdateNotification(
        title: '🛎️ Pesanan Baru!',
        body:
            'Pesanan dari ${user.email} - Total: Rp ${_formatPrice(totalPrice)}',
        topic: 'admin_orders',
      );

      await fetchOrders();

      Get.snackbar(
        'Berhasil',
        'Pesanan berhasil dibuat! Menunggu konfirmasi admin.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      if (kDebugMode) print('❌ Create order error: $e');

      Get.snackbar(
        'Gagal',
        'Gagal membuat pesanan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update order status (admin only)
  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      isLoading.value = true;

      await _supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId);

      await fetchOrders();

      Get.snackbar(
        'Berhasil',
        'Status pesanan diupdate',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Update order status error: $e');

      Get.snackbar(
        'Gagal',
        'Gagal update status: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get order by ID
  OrderModel? getOrderById(int id) {
    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Format price
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Get status color
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get status label
  String getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'preparing':
        return 'Sedang Diproses';
      case 'ready':
        return 'Siap Diambil';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}