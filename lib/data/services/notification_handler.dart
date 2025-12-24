import 'dart:convert';
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
    importance: Importance.defaultImportance,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('order'),
  );

  Future<void> initPushNotification() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    _firebaseMessaging.getToken().then((token) {
      print('FCM Token: $token');
    });

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    await _firebaseMessaging.subscribeToTopic('menu_updates');
    print('📢 Subscribed to menu_updates topic');

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _logNotification(
          message.notification?.title,
          message.notification?.body,
          'push',
        );
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _showNotificationPopup(
        title: notification.title ?? 'Notifikasi',
        body: notification.body ?? '',
      );

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
            playSound: true,
            sound: RawResourceAndroidNotificationSound('order'),
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );

      _logNotification(notification.title, notification.body, 'push');
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
        print('Local notification tapped: ${details.payload}');
      },
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // Request permission for Android 13+
    final androidPlugin = _localNotification
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

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
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'order.mp3',
      ),
    );

    await _localNotification.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );

    _logNotification(title, body, 'local');
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
