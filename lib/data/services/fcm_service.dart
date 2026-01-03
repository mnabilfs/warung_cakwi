import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  /// FCM scopes required for sending notifications
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  /// Cached access token
  AccessCredentials? _credentials;

  /// Get FCM HTTP v1 API endpoint
  String _getFcmUrl(String projectId) {
    return 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
  }

  /// Load service account credentials from assets
  Future<ServiceAccountCredentials> _loadServiceAccount() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/firebase-service-account.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ServiceAccountCredentials.fromJson(json);
    } catch (e) {
      throw Exception(
        'Failed to load service account. Make sure firebase-service-account.json '
        'is in assets folder and added to pubspec.yaml assets.',
      );
    }
  }

  /// Get OAuth2 access token
  Future<String> _getAccessToken() async {
    // Check if we have a valid cached token
    if (_credentials != null &&
        _credentials!.accessToken.expiry.isAfter(
          DateTime.now().add(const Duration(minutes: 5)),
        )) {
      return _credentials!.accessToken.data;
    }

    // Get new token
    final serviceAccount = await _loadServiceAccount();
    final client = http.Client();

    try {
      _credentials = await obtainAccessCredentialsViaServiceAccount(
        serviceAccount,
        _scopes,
        client,
      );
      return _credentials!.accessToken.data;
    } finally {
      client.close();
    }
  }

  /// Get project ID from service account
  Future<String> _getProjectId() async {
    final jsonString = await rootBundle.loadString(
      'assets/firebase-service-account.json',
    );
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return json['project_id'] as String;
  }

  /// Send notification to all users subscribed to a topic
  Future<bool> sendMenuUpdateNotification({
    required String title,
    required String body,
    String topic = 'menu_updates',
  }) async {
    try {
      if (kDebugMode) {
        print('📤 Sending FCM v1 notification: $title');
      }

      final accessToken = await _getAccessToken();
      final projectId = await _getProjectId();
      final fcmUrl = _getFcmUrl(projectId);

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'topic': topic,
            'notification': {'title': title, 'body': body},
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'type': 'menu_update',
            },
            'android': {
              'priority': 'high',
              'notification': {
                'sound': 'default',
                'channel_id': 'channel_notification',
              },
            },
            'apns': {
              'payload': {
                'aps': {'sound': 'default'},
              },
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print('✅ FCM v1 Notification sent successfully');
          print('📊 Response: ${responseData['name']}');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ FCM v1 Error: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending FCM v1 notification: $e');
      }
      return false;
    }
  }

  /// Send notification when menu is created
  Future<bool> notifyMenuCreated(String menuName) {
    return sendMenuUpdateNotification(
      title: 'Menu Baru! 🍜',
      body: 'Menu "$menuName" telah ditambahkan. Yuk cek sekarang!',
    );
  }

  /// Send notification when menu is updated
  Future<bool> notifyMenuUpdated(String menuName) {
    return sendMenuUpdateNotification(
      title: 'Update Menu 📝',
      body: 'Menu "$menuName" telah diperbarui.',
    );
  }

  /// Send notification when menu is deleted
  Future<bool> notifyMenuDeleted(String menuName) {
    return sendMenuUpdateNotification(
      title: 'Menu Dihapus 🗑️',
      body: 'Menu "$menuName" sudah tidak tersedia.',
    );
  }

  Future<bool> sendOrderStatusNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      if (kDebugMode) {
        print('📤 Sending order status notification to user: $userId');
      }

      final accessToken = await _getAccessToken();
      final projectId = await _getProjectId();
      final fcmUrl = _getFcmUrl(projectId);

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'topic': 'user_orders_$userId', // ✅ Topic spesifik per user
            'notification': {'title': title, 'body': body},
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'type': 'order_status_update',
              ...?data, // Tambahan data jika ada
            },
            'android': {
              'priority': 'high',
              'notification': {
                'sound': 'default',
                'channel_id': 'order_channel',
                'notification_priority': 'PRIORITY_MAX',
              },
            },
            'apns': {
              'payload': {
                'aps': {'sound': 'default', 'badge': 1},
              },
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print('✅ Order status notification sent successfully');
          print('📊 Response: ${responseData['name']}');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ FCM Error: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending order status notification: $e');
      }
      return false;
    }
  }

  /// Helper methods untuk setiap status order
  Future<bool> notifyOrderConfirmed(String userId, int orderId) {
    return sendOrderStatusNotification(
      userId: userId,
      title: '✅ Pesanan Dikonfirmasi!',
      body: 'Pesanan #$orderId Anda telah dikonfirmasi oleh penjual.',
      data: {'order_id': orderId.toString(), 'status': 'confirmed'},
    );
  }

  Future<bool> notifyOrderPreparing(String userId, int orderId) {
    return sendOrderStatusNotification(
      userId: userId,
      title: '👨‍🍳 Pesanan Sedang Diproses!',
      body: 'Pesanan #$orderId Anda sedang disiapkan.',
      data: {'order_id': orderId.toString(), 'status': 'preparing'},
    );
  }

  Future<bool> notifyOrderReady(String userId, int orderId) {
    return sendOrderStatusNotification(
      userId: userId,
      title: '🎉 Pesanan Siap!',
      body: 'Pesanan #$orderId Anda sudah siap untuk diambil!',
      data: {'order_id': orderId.toString(), 'status': 'ready'},
    );
  }

  Future<bool> notifyOrderCompleted(String userId, int orderId) {
    return sendOrderStatusNotification(
      userId: userId,
      title: '✨ Pesanan Selesai!',
      body: 'Terima kasih! Pesanan #$orderId telah selesai. Sampai jumpa lagi!',
      data: {'order_id': orderId.toString(), 'status': 'completed'},
    );
  }

  Future<bool> notifyOrderCancelled(
    String userId,
    int orderId,
    String? reason,
  ) {
    return sendOrderStatusNotification(
      userId: userId,
      title: '❌ Pesanan Dibatalkan',
      body: reason ?? 'Pesanan #$orderId Anda telah dibatalkan oleh penjual.',
      data: {'order_id': orderId.toString(), 'status': 'cancelled'},
    );
  }
}