import 'package:package_info_plus/package_info_plus.dart';

/// Semantic version comparison (major.minor.patch).
class VersionService {
  VersionService({PackageInfo? packageInfo}) : _packageInfo = packageInfo;

  PackageInfo? _packageInfo;

  Future<String> getCurrentAppVersion() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!.version;
  }

  /// Parses "1.2.3" into [major, minor, patch]. Returns null if invalid.
  List<int>? _parseVersion(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final parts = s.split('.');
    if (parts.isEmpty || parts.length > 4) return null;
    final out = <int>[];
    for (final p in parts) {
      final n = int.tryParse(p.trim());
      if (n == null || n < 0) return null;
      out.add(n);
    }
    while (out.length < 3) {
      out.add(0);
    }
    return out.take(3).toList();
  }

  /// -1 if [a] < [b], 0 if equal, 1 if [a] > [b].
  int compareVersions(String a, String b) {
    final pa = _parseVersion(a);
    final pb = _parseVersion(b);
    if (pa == null || pb == null) return 0;
    for (var i = 0; i < 3; i++) {
      if (pa[i] < pb[i]) return -1;
      if (pa[i] > pb[i]) return 1;
    }
    return 0;
  }

  bool isValidVersionString(String v) => _parseVersion(v) != null;

  /// Result of comparing current app version to Remote Config targets.
  ///
  /// - **Force**: `current < minimum_supported_version`
  /// - **Optional**: `current >= minimum_supported_version` and `current < latest_version`
  VersionCheckOutcome evaluate({
    required String currentVersion,
    required String minimumVersion,
    required String latestVersion,
  }) {
    if (!isValidVersionString(currentVersion) ||
        !isValidVersionString(minimumVersion) ||
        !isValidVersionString(latestVersion)) {
      return const VersionCheckOutcome.none();
    }

    final belowMin = compareVersions(currentVersion, minimumVersion) < 0;
    final belowLatest = compareVersions(currentVersion, latestVersion) < 0;

    if (belowMin) {
      return const VersionCheckOutcome(
        isUpdateRequired: true,
        isForceUpdate: true,
      );
    }

    // current >= minimum && current < latest → optional update
    if (belowLatest) {
      return const VersionCheckOutcome(
        isUpdateRequired: true,
        isForceUpdate: false,
      );
    }

    return const VersionCheckOutcome.none();
  }
}

/// Outcome of version vs Remote Config policy.
class VersionCheckOutcome {
  const VersionCheckOutcome({
    required this.isUpdateRequired,
    required this.isForceUpdate,
  });

  const VersionCheckOutcome.none()
      : isUpdateRequired = false,
        isForceUpdate = false;

  final bool isUpdateRequired;
  final bool isForceUpdate;
}
