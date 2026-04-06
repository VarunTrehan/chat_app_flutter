import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted storage for auth/session material. Uses platform secure storage
/// (Keychain / EncryptedSharedPreferences). Not a substitute for server-side auth.
class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  static const _authTokenKey = 'secure_auth_token';
  static const _sessionTokenKey = 'secure_session_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Persists the primary auth secret (e.g. Firebase ID token).
  Future<void> saveToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _authTokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  /// Secondary session material (refresh/session identifiers you control).
  Future<void> saveSessionToken(String token) async {
    await _storage.write(key: _sessionTokenKey, value: token);
  }

  Future<String?> getSessionToken() async {
    return _storage.read(key: _sessionTokenKey);
  }

  Future<void> deleteSessionToken() async {
    await _storage.delete(key: _sessionTokenKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Stores arbitrary sensitive keys (API secrets, etc.). Prefer narrow methods when possible.
  Future<void> writeSensitiveKey(String key, String value) async {
    await _storage.write(key: 'sk_$key', value: value);
  }

  Future<String?> readSensitiveKey(String key) async {
    return _storage.read(key: 'sk_$key');
  }

  Future<void> deleteSensitiveKey(String key) async {
    await _storage.delete(key: 'sk_$key');
  }

  Future<void> cacheAuthFromFirebaseUser(User user) async {
    try {
      final token = await user.getIdToken();
      if (token != null && token.isNotEmpty) {
        await saveToken(token);
      }
    } catch (e, st) {
      debugPrint('SecureStorageService.cacheAuthFromFirebaseUser: $e\n$st');
    }
  }
}
