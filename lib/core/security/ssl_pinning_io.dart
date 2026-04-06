import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

bool _installed = false;

void installSslPinning({
  required bool enabled,
  required Map<String, List<String>> hostSha256HexPins,
  required bool allowInsecureFallbackInDebugOnMismatch,
}) {
  if (_installed) {
    return;
  }
  _installed = true;
  if (!enabled || hostSha256HexPins.isEmpty) {
    return;
  }

  final normalized = <String, List<String>>{};
  for (final e in hostSha256HexPins.entries) {
    normalized[e.key.toLowerCase()] = e.value
        .map((h) => h.toLowerCase().replaceAll(':', '').replaceAll(' ', ''))
        .toList();
  }

  HttpOverrides.global = _PinnedHttpOverrides(
    pins: normalized,
    debugFallbackOnMismatch: allowInsecureFallbackInDebugOnMismatch,
  );
}

class _PinnedHttpOverrides extends HttpOverrides {
  _PinnedHttpOverrides({
    required this.pins,
    required this.debugFallbackOnMismatch,
  });

  final Map<String, List<String>> pins;
  final bool debugFallbackOnMismatch;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      final expected = pins[host.toLowerCase()];
      if (expected == null || expected.isEmpty) {
        return false;
      }
      final digest = sha256.convert(cert.der);
      final hex = digest.bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      if (expected.contains(hex)) {
        return true;
      }
      debugPrint('SSL pin mismatch for $host (expected one of $expected, got $hex)');
      if (kDebugMode && debugFallbackOnMismatch) {
        debugPrint('Allowing connection in debug due to fallback policy.');
        return true;
      }
      return false;
    };
    return client;
  }
}
