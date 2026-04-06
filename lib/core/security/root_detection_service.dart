import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';

import 'io_compat.dart';

/// Root / jailbreak detection using [SafeDevice].
class RootDetectionService {
  RootDetectionService._();

  /// `true` when the device appears rooted (Android) or jailbroken (iOS).
  /// Always `false` on web and non-mobile desktop targets.
  static Future<bool> isDeviceRooted() async {
    if (kIsWeb || !securityIsMobile) {
      return false;
    }
    try {
      SafeDevice.ensureInitiated();
      return SafeDevice.isJailBroken;
    } catch (e, st) {
      debugPrint('RootDetectionService: $e\n$st');
      return false;
    }
  }
}
