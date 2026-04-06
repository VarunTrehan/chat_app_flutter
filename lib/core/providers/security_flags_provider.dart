import 'package:flutter/foundation.dart';

/// When [sensitiveFeaturesInitiallyDisabled] is true (e.g. emulator), VoIP / call
/// entry points should hide or no-op.
class SecurityFlags extends ChangeNotifier {
  SecurityFlags({bool sensitiveFeaturesInitiallyDisabled = false})
      : _sensitiveFeaturesEnabled = !sensitiveFeaturesInitiallyDisabled;

  bool _sensitiveFeaturesEnabled;

  bool get sensitiveFeaturesEnabled => _sensitiveFeaturesEnabled;

  void disableSensitiveFeatures() {
    if (!_sensitiveFeaturesEnabled) {
      return;
    }
    _sensitiveFeaturesEnabled = false;
    notifyListeners();
  }
}
