import 'dart:async';

import 'package:chat_app_flutter/models/user_model.dart';
import 'package:chat_app_flutter/services/auth_services.dart';
import 'package:chat_app_flutter/core/services/cache_service.dart';
import 'package:chat_app_flutter/core/services/network_service.dart';
import 'package:flutter/foundation.dart';

/// Offline-first data provider for key app modules.
///
/// Currently caches:
/// - All users list (HomeScreen)
/// - Current user profile (Home/Profile)
class OfflineDataProvider extends ChangeNotifier {
  static const String _cacheUsersKey = 'cached_users';
  static const String _cacheCurrentUserKey = 'cached_current_user';

  final AuthServices _authServices;
  final CacheService _cacheService;
  final NetworkService _networkService;

  final StreamController<List<UserModel>> _usersController =
      StreamController<List<UserModel>>.broadcast();

  StreamSubscription<bool>? _networkSub;
  StreamSubscription<List<UserModel>>? _usersSub;

  bool _initialized = false;
  bool _isOnline = false;

  bool get initialized => _initialized;
  bool get isOnline => _isOnline;

  Stream<List<UserModel>> get usersStream => _usersController.stream;

  OfflineDataProvider({
    required AuthServices authServices,
    required CacheService cacheService,
    required NetworkService networkService,
  })  : _authServices = authServices,
        _cacheService = cacheService,
        _networkService = networkService {
    // Kick off initialization.
    unawaited(loadData());
  }

  Future<void> loadData() async {
    _isOnline = await _networkService.isOnline();

    // Load cached users immediately so the UI can render offline data.
    await loadFromCache();

    // Then subscribe/sync when online.
    if (_isOnline) {
      await syncWhenOnline();
    }

    // Keep cache fresh when connectivity changes.
    _networkSub = _networkService.streamNetworkStatus().listen((online) async {
      _isOnline = online;
      if (online) {
        await syncWhenOnline();
      } else {
        await _stopFirestoreSync();
        await loadFromCache();
      }
      notifyListeners();
    });

    _initialized = true;
    notifyListeners();
  }

  Future<void> loadFromCache() async {
    final cached = await _cacheService.getData(_cacheUsersKey);

    if (cached is List) {
      final users = cached
          .map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        final uid = map['uid']?.toString();
        if (uid == null || uid.isEmpty) return null;
        return UserModel.fromMap(map, uid);
      }).whereType<UserModel>().toList();
      _usersController.add(users);
      return;
    }

    // No cache: emit empty state.
    _usersController.add(const <UserModel>[]);
  }

  Future<void> syncWhenOnline() async {
    if (_usersSub != null) return; // Already syncing.

    _usersSub = _authServices.getAllUsers().listen(
          (users) async {
            // Cache the latest users snapshot.
            await _cacheService.saveData(
              _cacheUsersKey,
              users.map((u) => u.toMap()).toList(),
            );
            _usersController.add(users);
          },
          onError: (Object _) async {
            // Firestore failed; fall back to cached data if possible.
            await loadFromCache();
          },
          cancelOnError: false,
        );
  }

  Future<void> _stopFirestoreSync() async {
    await _usersSub?.cancel();
    _usersSub = null;
  }

  /// Loads current user profile:
  /// - If online, try API first; on failure, fall back to cache.
  /// - If offline, return cached profile (if available).
  Future<UserModel?> loadCurrentUser() async {
    final canUseNetwork = await _networkService.isOnline();

    if (canUseNetwork) {
      try {
        final user = await _authServices.getCurrentUserData();
        if (user != null) {
          await _cacheService.saveData(_cacheCurrentUserKey, user.toMap());
        }
        return user;
      } catch (_) {
        // Ignore and fall back to cache.
      }
    }

    final cached = await _cacheService.getData(_cacheCurrentUserKey);
    if (cached is Map) {
      final map = Map<String, dynamic>.from(cached);
      final uid = map['uid'] as String?;
      if (uid != null) {
        return UserModel.fromMap(map, uid);
      }
    }
    return null;
  }

  @override
  void dispose() {
    _networkSub?.cancel();
    _usersSub?.cancel();
    _usersController.close();
    super.dispose();
  }
}

