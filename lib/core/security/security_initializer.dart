import 'package:chat_app_flutter/core/security/emulator_detection_service.dart';
import 'package:chat_app_flutter/core/security/io_compat.dart';
import 'package:chat_app_flutter/core/security/root_detection_service.dart';
import 'package:chat_app_flutter/core/security/secure_storage_service.dart';
import 'package:chat_app_flutter/core/security/ssl_pinning_service.dart';
import 'package:chat_app_flutter/core/security/tamper_detection_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Runs startup security: SSL pinning hook-up, secure storage warm-up, and
/// mobile integrity checks. Call [initializeSslPinning] before any Dart HTTP
/// or [Firebase.initializeApp] if you rely on [HttpClient] with the same process.
class SecurityInitializer {
  SecurityInitializer._();

  static const _expectedAndroidSignature = String.fromEnvironment(
    'EXPECTED_ANDROID_SIGNATURE',
    defaultValue: '',
  );

  /// Installs [HttpOverrides] when `SSL_PINNING_ENABLED` is true and you add
  /// non-empty pins in code (see [SslPinningService]). Default: pinning off.
  static void initializeSslPinning({
    bool? enabled,
    Map<String, List<String>> hostSha256HexPins = const {},
    bool allowInsecureFallbackInDebugOnMismatch = true,
  }) {
    final pinEnabled = enabled ??
        const bool.fromEnvironment('SSL_PINNING_ENABLED', defaultValue: false);
    SslPinningService.initialize(
      enabled: pinEnabled,
      hostSha256HexPins: hostSha256HexPins,
      allowInsecureFallbackInDebugOnMismatch:
          allowInsecureFallbackInDebugOnMismatch,
    );
  }

  /// Touch secure storage early so failures surface before UI.
  static Future<void> initializeSecureStorage() async {
    try {
      await SecureStorageService.instance.getToken();
    } catch (e, st) {
      debugPrint('SecurityInitializer.initializeSecureStorage: $e\n$st');
    }
  }

  static Future<bool> runRootCheck() => RootDetectionService.isDeviceRooted();

  static Future<bool> runEmulatorCheck() =>
      EmulatorDetectionService.isLikelyEmulator();

  static Future<TamperCheckResult> runTamperCheck() {
    return TamperDetectionService.evaluate(
      expectedAndroidSignature:
          _expectedAndroidSignature.isEmpty ? null : _expectedAndroidSignature,
    );
  }

  /// Ordered checks: tamper (session end) → root → emulator (soft signal only).
  static Future<SecurityBootstrapOutcome> evaluateDeviceSecurity() async {
    if (kIsWeb || !securityIsMobile) {
      return const SecurityBootstrapOutcome(
        blocked: false,
        emulatorSuspicious: false,
      );
    }

    final tamper = await runTamperCheck();
    if (tamper.isTampered) {
      await _terminateSessionAfterTamper();
      return SecurityBootstrapOutcome(
        blocked: true,
        blockMessage: tamper.message ?? 'Security check failed.',
      );
    }

    if (await runRootCheck()) {
      await SecureStorageService.instance.clearAll();
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e, st) {
        debugPrint('SecurityInitializer root signOut: $e\n$st');
      }
      return const SecurityBootstrapOutcome(
        blocked: true,
        blockMessage:
            'This app cannot run on modified devices (root or jailbreak detected).',
      );
    }

    final emulatorSuspicious = await runEmulatorCheck();
    return SecurityBootstrapOutcome(
      blocked: false,
      emulatorSuspicious: emulatorSuspicious,
    );
  }

  static Future<void> _terminateSessionAfterTamper() async {
    await SecureStorageService.instance.clearAll();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e, st) {
      debugPrint('SecurityInitializer tamper signOut: $e\n$st');
    }
  }
}

class SecurityBootstrapOutcome {
  const SecurityBootstrapOutcome({
    required this.blocked,
    this.blockMessage,
    this.emulatorSuspicious = false,
  });

  final bool blocked;
  final String? blockMessage;
  final bool emulatorSuspicious;
}
