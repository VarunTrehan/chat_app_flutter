import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';

import 'io_compat.dart';

/// Heuristic emulator / virtual device detection (AVD, Genymotion, BlueStacks-style).
class EmulatorDetectionService {
  EmulatorDetectionService._();

  static Future<bool> isLikelyEmulator() async {
    if (kIsWeb || !securityIsMobile) {
      return false;
    }
    try {
      SafeDevice.ensureInitiated();
      final notReal = !await SafeDevice.isRealDevice;
      if (notReal) {
        return true;
      }
      if (securityIsAndroid) {
        return _androidEmulatorHeuristics();
      }
      if (securityIsIOS) {
        return _iosSimulatorHeuristics();
      }
    } catch (e, st) {
      debugPrint('EmulatorDetectionService: $e\n$st');
    }
    return false;
  }

  static Future<bool> _androidEmulatorHeuristics() async {
    final info = await DeviceInfoPlugin().androidInfo;
    if (!info.isPhysicalDevice) {
      return true;
    }
    final fingerprint = info.fingerprint.toLowerCase();
    final model = info.model.toLowerCase();
    final manufacturer = info.manufacturer.toLowerCase();
    final brand = info.brand.toLowerCase();
    final product = info.product.toLowerCase();

    const emulatorHints = [
      'generic',
      'unknown',
      'emulator',
      'android sdk built for',
      'genymotion',
      'goldfish',
      'ranchu',
      'vbox',
      'ttvm', // BlueStacks-style
      'bluestacks',
    ];

    final combined = '$fingerprint $model $manufacturer $brand $product';
    for (final hint in emulatorHints) {
      if (combined.contains(hint)) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> _iosSimulatorHeuristics() async {
    final info = await DeviceInfoPlugin().iosInfo;
    return !info.isPhysicalDevice;
  }
}
