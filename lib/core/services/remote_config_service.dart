import 'package:chat_app_flutter/core/services/version_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Firebase Remote Config keys for app update policy.
///
/// Configure in Firebase Console → Remote Config:
/// - [minimumSupportedVersionKey]
/// - [latestVersionKey]
/// - [updateRequiredKey]
/// - [updateUrlKey]
class RemoteConfigService {
  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _rc = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _rc;

  static const String minimumSupportedVersionKey = 'minimum_supported_version';
  static const String latestVersionKey = 'latest_version';
  static const String updateRequiredKey = 'update_required';
  static const String updateUrlKey = 'update_url';

  /// Call after [Firebase.initializeApp]. Safe to call multiple times.
  Future<void> initializeRemoteConfig() async {
    await _rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: const Duration(minutes: 5),
      ),
    );
    await _rc.setDefaults(<String, dynamic>{
      minimumSupportedVersionKey: '0.0.0',
      latestVersionKey: '0.0.0',
      updateRequiredKey: false,
      updateUrlKey: '',
    });
  }

  /// Fetches from Remote Config and applies. On failure, last activated values remain.
  Future<void> fetchRemoteConfig() async {
    await _rc.fetchAndActivate();
  }

  String getMinimumVersion() => _rc.getString(minimumSupportedVersionKey).trim();

  String getLatestVersion() => _rc.getString(latestVersionKey).trim();

  bool getUpdateRequired() => _rc.getBool(updateRequiredKey);

  String getUpdateUrl() => _rc.getString(updateUrlKey).trim();

  /// `true` when [currentVersion] is below [minimum_supported_version].
  bool isForceUpdateRequired(VersionService versionService, String currentVersion) {
    return versionService.compareVersions(currentVersion, getMinimumVersion()) < 0;
  }

  /// `true` when optional update applies: current ≥ minimum and current < latest.
  bool isOptionalUpdateAvailable(VersionService versionService, String currentVersion) {
    if (versionService.compareVersions(currentVersion, getMinimumVersion()) < 0) {
      return false;
    }
    return versionService.compareVersions(currentVersion, getLatestVersion()) < 0;
  }
}
