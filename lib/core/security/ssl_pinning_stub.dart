import 'package:flutter/foundation.dart';

void installSslPinning({
  required bool enabled,
  required Map<String, List<String>> hostSha256HexPins,
  required bool allowInsecureFallbackInDebugOnMismatch,
}) {
  if (enabled && hostSha256HexPins.isNotEmpty) {
    debugPrint(
      'SSL pinning via HttpOverrides is not supported on web; pins were not applied.',
    );
  }
}
