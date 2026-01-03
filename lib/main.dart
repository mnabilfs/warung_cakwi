import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'data/providers/notification_provider.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/notification_handler.dart';
import 'data/services/notification_service.dart';

import 'pages/login_page.dart';
import 'pages/landing_page.dart';

import 'data/controllers/theme_controller.dart';
import 'data/controllers/menu_controller.dart';
import 'data/controllers/auth_controller.dart';
import 'data/controllers/weather_recommendation_controller.dart';
import 'data/controllers/order_controller.dart';

import 'theme/app_theme.dart';

/// =======================================================
/// 🔔 FCM BACKGROUND HANDLER (WAJIB TOP LEVEL)
/// =======================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('📨 Background message: ${message.messageId}');
}

/// =======================================================
/// 🚀 MAIN
/// =======================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Load ENV
  await dotenv.load(fileName: ".env");

  /// Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Register background handler
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  /// Initialize Notification Service (FCM + Local)
  final notificationService = NotificationService();
  await notificationService.initialize();

  /// Init Local Storage
  await Get.putAsync<LocalStorageService>(
    () async => await LocalStorageService().init(),
  );

  /// Init Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  /// Register GetX Controllers
  Get.put(NotificationProvider());
  Get.put(AuthController());
  Get.put(ThemeController());
  Get.put(MenuController());
  Get.lazyPut(() => WeatherRecommendationController(), fenix: true);
  Get.put(OrderController());

  /// Init Notification Handler (LOCAL NOTIF)
  final notificationHandler = NotificationHandler();
  await notificationHandler.initLocalNotification();
  await notificationHandler.initPushNotification();

  runApp(const WarungCakwiApp());
}

/// =======================================================
/// 🌈 APP ROOT
/// =======================================================
class WarungCakwiApp extends StatelessWidget {
  const WarungCakwiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Warung Cakwi',
        debugShowCheckedModeBanner: false,

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,

        home: const AuthGate(),

        getPages: [
          GetPage(name: '/', page: () => const AuthGate()),
          GetPage(name: '/login', page: () => const LoginPage()),
          GetPage(name: '/home', page: () => LandingPage()),
        ],
      ),
    );
  }
}

/// =======================================================
/// 🔐 AUTH GATE (SUPABASE)
/// =======================================================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return LandingPage();
    } else {
      return const LoginPage();
    }
  }
}
