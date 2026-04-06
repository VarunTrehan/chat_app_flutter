import 'ssl_pinning_io.dart' if (dart.library.html) 'ssl_pinning_stub.dart'
    as ssl_impl;

/// TLS pinning for [dart:io] [HttpClient] via [HttpOverrides].
///
/// **Does not pin** Firebase, Zego, or other native HTTP clients. Configure
/// pins only for hosts you reach with Dart's [HttpClient], or add native
/// pinning separately. Leave [enabled] false until real SHA-256 (leaf DER)
/// fingerprints are supplied.
class SslPinningService {
  SslPinningService._();

  static bool _requested = false;

  /// Set [enabled] true and non-empty [hostSha256HexPins] only after extracting
  /// production certificate digests. Mismatch: blocked in release; in debug,
  /// [allowInsecureFallbackInDebugOnMismatch] permits the connection and logs.
  static void initialize({
    bool enabled = false,
    Map<String, List<String>> hostSha256HexPins = const {},
    bool allowInsecureFallbackInDebugOnMismatch = true,
  }) {
    if (_requested) {
      return;
    }
    _requested = true;
    ssl_impl.installSslPinning(
      enabled: enabled,
      hostSha256HexPins: hostSha256HexPins,
      allowInsecureFallbackInDebugOnMismatch:
          allowInsecureFallbackInDebugOnMismatch,
    );
  }
}
