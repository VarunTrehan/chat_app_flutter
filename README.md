# chat_app_flutter

A new Flutter project.

## Release builds with code obfuscation

To ship a release APK with Dart symbol stripping and separate debug symbols (for crash de-obfuscation), run:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

- Store the `split-debug-info` output securely; you need it to translate stack traces from obfuscated builds.
- iOS: use the same flags with `flutter build ipa` if you distribute via the App Store or TestFlight.

## Security features (overview)

Startup logic in `lib/core/security/` covers encrypted storage (`flutter_secure_storage`), optional `HttpClient` TLS pinning (`SslPinningService` — does not pin Firebase/Zego native traffic), root/jailbreak checks, emulator heuristics (calls UI disabled when flagged), and release tamper heuristics. See `SecurityInitializer` in `lib/main.dart` for the bootstrap order.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
