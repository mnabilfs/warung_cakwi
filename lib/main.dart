import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'data/providers/notification_provider.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/notification_handler.dart';

import 'pages/login_page.dart';
import 'pages/landing_page.dart';

// import 'data/models/menu_item.dart';
import 'data/controllers/theme_controller.dart';
import 'data/controllers/menu_controller.dart';
import 'data/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await Hive.initFlutter();
  // Hive.registerAdapter(MenuItemAdapter());

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await Get.putAsync<LocalStorageService>(
    () async => await LocalStorageService().init(),
  );

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  Get.put(NotificationProvider());
  Get.put(AuthController());
  Get.put(ThemeController());
  Get.put(MenuController());

  final notificationHandler = NotificationHandler();
  await notificationHandler.initLocalNotification();
  await notificationHandler.initPushNotification();

  runApp(const WarungCakwiApp());
}

class WarungCakwiApp extends StatelessWidget {
  const WarungCakwiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Warung Cakwi',
      debugShowCheckedModeBanner: false,

      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFD4A017),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4A017),
          secondary: Color(0xFFD4A017),
          surface: Color(0xFF2D2D2D),
        ),
      ),
      themeMode: themeController.isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,

      home: const AuthGate(),

      getPages: [
        GetPage(name: '/', page: () => const AuthGate()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => LandingPage()),
      ],
    );
  }
}

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
