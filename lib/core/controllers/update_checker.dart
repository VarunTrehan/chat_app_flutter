import 'package:chat_app_flutter/core/services/remote_config_service.dart';
import 'package:chat_app_flutter/core/services/version_service.dart';
import 'package:chat_app_flutter/core/widgets/update_dialog.dart';
import 'package:flutter/material.dart';

/// Result of [UpdateChecker.checkForUpdates] when an update should be shown.
class UpdateCheckResult {
  const UpdateCheckResult({
    required this.isForceUpdate,
    required this.title,
    required this.description,
    required this.updateUrl,
  });

  final bool isForceUpdate;
  final String title;
  final String description;
  final String updateUrl;
}

/// Coordinates Remote Config fetch, version read, and update policy.
class UpdateChecker {
  UpdateChecker({
    RemoteConfigService? remoteConfigService,
    VersionService? versionService,
  })  : _remote = remoteConfigService ?? RemoteConfigService(),
        _version = versionService ?? VersionService();

  final RemoteConfigService _remote;
  final VersionService _version;

  /// Returns `null` when no dialog should be shown (no update, network/config failure, invalid data).
  Future<UpdateCheckResult?> checkForUpdates() async {
    try {
      await _remote.fetchRemoteConfig();
    } catch (_) {
      return null;
    }

    late final String current;
    try {
      current = await _version.getCurrentAppVersion();
    } catch (_) {
      return null;
    }

    final min = _remote.getMinimumVersion();
    final latest = _remote.getLatestVersion();
    final url = _remote.getUpdateUrl();

    if (!_version.isValidVersionString(current) ||
        !_version.isValidVersionString(min) ||
        !_version.isValidVersionString(latest)) {
      return null;
    }

    if (url.isEmpty) {
      return null;
    }

    final outcome = _version.evaluate(
      currentVersion: current,
      minimumVersion: min,
      latestVersion: latest,
    );

    if (!outcome.isUpdateRequired) {
      return null;
    }

    if (outcome.isForceUpdate) {
      return UpdateCheckResult(
        isForceUpdate: true,
        title: 'Update required',
        description:
            'This version is no longer supported. Please update to continue using the app.',
        updateUrl: url,
      );
    }

    return UpdateCheckResult(
      isForceUpdate: false,
      title: 'Update available',
      description:
          'A newer version is available. Update now for the latest improvements.',
      updateUrl: url,
    );
  }

  Future<void> checkAndShowDialogIfNeeded(BuildContext context) async {
    final result = await checkForUpdates();
    if (!context.mounted || result == null) return;

    await showUpdateDialog(
      context: context,
      title: result.title,
      description: result.description,
      isForceUpdate: result.isForceUpdate,
      updateUrl: result.updateUrl,
    );
  }
}

/// Runs one update check after the first frame and shows [UpdateDialog] when needed.
class UpdateAppStartup extends StatefulWidget {
  const UpdateAppStartup({
    super.key,
    required this.remoteConfig,
    required this.child,
  });

  final RemoteConfigService remoteConfig;
  final Widget child;

  @override
  State<UpdateAppStartup> createState() => _UpdateAppStartupState();
}

class _UpdateAppStartupState extends State<UpdateAppStartup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (!mounted) return;
    final checker = UpdateChecker(remoteConfigService: widget.remoteConfig);
    await checker.checkAndShowDialogIfNeeded(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
