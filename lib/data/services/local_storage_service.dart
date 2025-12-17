import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/menu_item.dart';
import '../models/notification_log_model.dart';

class LocalStorageService extends GetxService {
  // Box names
  static const String menuBoxName = 'menu_cache';
  static const String cartBoxName = 'cart_cache';
  static const String settingsBoxName = 'settings_cache';
  static const String notificationBoxName = 'notification_log_box';

  // Boxes
  late final Box<MenuItem> _menuBox;
  late final Box<MenuItem> _cartBox;
  late final Box _settingsBox;
  late final Box<NotificationLogModel> _notificationBox;

  // Getters
  Box<MenuItem> get menuBox => _menuBox;
  Box<MenuItem> get cartBox => _cartBox;
  Box get settingsBox => _settingsBox;
  Box<NotificationLogModel> get notificationBox => _notificationBox;

  Future<LocalStorageService> init() async {
    /// =============================
    /// INIT HIVE
    /// =============================
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDir.path);
    }

    /// =============================
    /// REGISTER ADAPTERS (WAJIB)
    /// =============================
    if (!Hive.isAdapterRegistered(MenuItemAdapter().typeId)) {
      Hive.registerAdapter(MenuItemAdapter());
    }

    if (!Hive.isAdapterRegistered(NotificationLogModelAdapter().typeId)) {
      Hive.registerAdapter(NotificationLogModelAdapter());
    }

    /// =============================
    /// OPEN BOXES
    /// =============================
    _menuBox = await Hive.openBox<MenuItem>(menuBoxName);
    _cartBox = await Hive.openBox<MenuItem>(cartBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
    _notificationBox =
        await Hive.openBox<NotificationLogModel>(notificationBoxName);

    debugPrint('✅ Hive initialized & boxes opened');
    debugPrint('📦 menuBox: ${_menuBox.length}');
    debugPrint('🛒 cartBox: ${_cartBox.length}');
    debugPrint('⚙️ settingsBox: ${_settingsBox.length}');
    debugPrint('🔔 notificationBox: ${_notificationBox.length}');

    return this;
  }

  Future<void> close() async {
    await _menuBox.close();
    await _cartBox.close();
    await _settingsBox.close();
    await _notificationBox.close();
  }
}
