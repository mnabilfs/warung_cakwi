import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_notification',
        'High Importance Notification',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _localNotification.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      details,
    );

    _logNotification(title, body, 'local');
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
