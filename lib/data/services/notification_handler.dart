// lib\data\services\notification_handler.dart
import 'dart:convert';
import 'dart:io'; // ✅ TAMBAHKAN INI untuk Platform check
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../providers/notification_provider.dart';
import '../models/notification_log_model.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Pesan diterima di background: ${message.notification?.title}');
}

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotification =
      FlutterLocalNotificationsPlugin();

  /// ✅ AMBIL provider yang SUDAH di-init di main.dart
  NotificationProvider get _notificationProvider =>
      Get.find<NotificationProvider>();

  final _androidChannel = const AndroidNotificationChannel(
    'channel_notification',
    'High Importance Notification',
    description: 'Used For Notification',
    importance: Importance.max, // ✅ UBAH ke max untuk notifikasi penting
    playSound: true,
    sound: RawResourceAndroidNotificationSound('order'),
  );

  /// ✅ TAMBAHKAN METHOD INI - Request notification permission untuk Android 13+
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _localNotification
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        print('🔔 Notification permission granted: $granted');
        return granted ?? false;
      }
    }
    return true; // iOS handles this automatically
  }

  Future<void> initPushNotification() async {
    // ✅ Request FCM permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // Set ke false agar permission dialog muncul
    );

    print('🔔 FCM Permission status: ${settings.authorizationStatus}');

    _firebaseMessaging.getToken().then((token) {
      print('📱 FCM Token: $token');
    });

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    // ✅ Subscribe ke topic menu_updates DAN admin_orders
    await _firebaseMessaging.subscribeToTopic('menu_updates');
    await _firebaseMessaging.subscribeToTopic('admin_orders');
    print('📢 Subscribed to menu_updates topic');
    print('📢 Subscribed to admin_orders topic');

    // Handle initial message (app opened from terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('📬 Initial message: ${message.notification?.title}');
        _logNotification(
          message.notification?.title,
          message.notification?.body,
          'push',
        );
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) {
        print('⚠️ Received message without notification payload');
        return;
      }

      print('📬 Foreground message: ${notification.title}');

      // Show popup dialog
      _showNotificationPopup(
        title: notification.title ?? 'Notifikasi',
        body: notification.body ?? '',
      );

      // Show local notification
      _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('order'),
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'order.mp3',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );

      _logNotification(notification.title, notification.body, 'push');
    });

    // Handle message opened from background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('📬 Message opened from background: ${message.notification?.title}');
      _logNotification(
        message.notification?.title,
        message.notification?.body,
        'push',
      );
    });
  }

  Future<void> initLocalNotification() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print('🔔 Local notification tapped: ${details.payload}');
      },
    );

    // ✅ PERBAIKAN: Buat notification channels secara eksplisit
    final androidPlugin = _localNotification
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // Channel untuk order notifications
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'order_channel',
          'Order Notification',
          description: 'Notifikasi untuk pesanan',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('order'),
          enableVibration: true,
        ),
      );

      // Channel untuk default notification (dari FCM)
      await androidPlugin.createNotificationChannel(_androidChannel);
      
      print('✅ Notification channels created');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    print('🔔 Showing local notification: $title');

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'order_channel',
        'Order Notification',
        channelDescription: 'Notifikasi untuk pesanan',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('order'),
        enableVibration: true,
        showWhen: true,
        styleInformation: BigTextStyleInformation(''), // ✅ Untuk teks panjang
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'order.mp3',
      ),
    );

    try {
      await _localNotification.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
      );

      print('✅ Local notification shown successfully');
      _logNotification(title, body, 'local');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  void _showNotificationPopup({
    required String title,
    required String body,
  }) {
    if (Get.isDialogOpen == true) return; // Prevent multiple dialogs

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Color(0xFFD4A017),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFD4A017),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          body,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Get.context != null) {
                Navigator.of(Get.context!).pop();
              }
            },
            child: const Text(
              'Tutup',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A017),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (Get.context != null) {
                Navigator.of(Get.context!).pop();
              }
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _logNotification(String? title, String? body, String type) {
    if (title == null) return;

    _notificationProvider.addLog(
      NotificationLogModel(
        title: title,
        body: body ?? '',
        timestamp: DateTime.now(),
        type: type,
      ),
    );
  }
}