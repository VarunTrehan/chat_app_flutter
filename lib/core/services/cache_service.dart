import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple offline cache abstraction backed by Hive.
///
/// - Stores JSON-serialized data in a string box.
/// - Tracks cache availability with SharedPreferences for quick checks (non-secret flags only; use secure storage for tokens).
class CacheService {
  static const String _availabilityPrefix = 'cache_available_';

  final Box<String> _box;
  final SharedPreferences _prefs;

  CacheService._(this._box, this._prefs);

  static Future<CacheService> init({
    String hiveBoxName = 'app_cache',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final box = await Hive.openBox<String>(hiveBoxName);
    return CacheService._(box, prefs);
  }

  Future<void> saveData(String key, dynamic data) async {
    final jsonString = jsonEncode(data);
    await _box.put(key, jsonString);
    await _prefs.setBool('$_availabilityPrefix$key', true);
  }

  /// Returns decoded JSON data or `null` if no cache exists.
  Future<dynamic> getData(String key) async {
    if (!isCacheAvailable(key)) return null;
    final jsonString = _box.get(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  Future<void> clearData(String key) async {
    await _box.delete(key);
    await _prefs.setBool('$_availabilityPrefix$key', false);
  }

  bool isCacheAvailable(String key) {
    return _prefs.getBool('$_availabilityPrefix$key') ?? false;
  }
}

