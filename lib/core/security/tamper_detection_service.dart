import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'io_compat.dart';

/// Best-effort integrity checks. Debug builds skip hard blocks so local
/// development keeps working.
class TamperDetectionService {
  TamperDetectionService._();

  /// [expectedAndroidSignature]: optional value from
  /// `--dart-define=EXPECTED_ANDROID_SIGNATURE=...`, compared to Android
  /// [PackageInfo.buildSignature] when both are non-empty.
  static Future<TamperCheckResult> evaluate({
    String? expectedAndroidSignature,
  }) async {
    if (kIsWeb) {
      return TamperCheckResult.ok();
    }
    if (kDebugMode) {
      return TamperCheckResult.ok();
    }

    if (await detectHookingFrameworks()) {
      debugPrint('security: tamper — hooking heuristic matched');
      return TamperCheckResult.tampered(
        'This environment failed an integrity check.',
      );
    }

    if (securityIsAndroid) {
      final info = await PackageInfo.fromPlatform();
      final expected = expectedAndroidSignature;
      if (expected != null &&
          expected.isNotEmpty &&
          info.buildSignature.isNotEmpty &&
          info.buildSignature != expected) {
        debugPrint('security: tamper — app signature mismatch');
        return TamperCheckResult.tampered(
          'Application signature does not match the expected release signing key.',
        );
      }
    }

    return TamperCheckResult.ok();
  }

  static Future<bool> detectHookingFrameworks() async {
    if (!securityIsAndroid) {
      return false;
    }
    const paths = <String>[
      '/data/local/tmp/re.frida.server',
      '/data/local/tmp/frida-server',
      '/system/lib/libsubstrate.so',
      '/system/framework/XposedBridge.jar',
    ];
    for (final p in paths) {
      if (securityFileExists(p)) {
        return true;
      }
    }
    return false;
  }
}

class TamperCheckResult {
  const TamperCheckResult._({required this.isTampered, this.message});

  final bool isTampered;
  final String? message;

  factory TamperCheckResult.ok() =>
      const TamperCheckResult._(isTampered: false);

  factory TamperCheckResult.tampered(String message) =>
      TamperCheckResult._(isTampered: true, message: message);
}
