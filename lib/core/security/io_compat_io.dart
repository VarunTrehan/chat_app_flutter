import 'dart:io';

bool get securityIsAndroid => Platform.isAndroid;

bool get securityIsIOS => Platform.isIOS;

bool get securityIsMobile => Platform.isAndroid || Platform.isIOS;

bool securityFileExists(String path) {
  try {
    return File(path).existsSync();
  } catch (_) {
    return false;
  }
}
