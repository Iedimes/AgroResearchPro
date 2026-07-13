import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  static Future<Box<Map<String, dynamic>>> openBox(String name) async {
    if (!_initialized) await init();
    if (Hive.isBoxOpen(name)) {
      return Hive.box<Map<String, dynamic>>(name);
    }
    return Hive.openBox<Map<String, dynamic>>(name);
  }

  static Future<void> closeAll() async {
    await Hive.close();
    _initialized = false;
  }
}
