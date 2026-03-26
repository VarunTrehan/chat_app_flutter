import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  late Map<String, String> _localizedStrings;

  static Map<String, String> _englishStrings = const {};
  static bool _englishLoaded = false;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  Future<void> _ensureEnglishLoaded() async {
    if (_englishLoaded) return;
    final jsonString = await rootBundle.loadString('assets/lang/en.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _englishStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    _englishLoaded = true;
  }

  Future<bool> load() async {
    final jsonString = await rootBundle.loadString(
      'assets/lang/${locale.languageCode}.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    await _ensureEnglishLoaded();
    return true;
  }

  String _applyArgs(String template, Map<String, Object>? args) {
    if (args == null || args.isEmpty) return template;
    var result = template;
    for (final entry in args.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value.toString());
    }
    return result;
  }

  String translate(String key, {Map<String, Object>? args}) {
    final template = _localizedStrings[key] ?? key;
    return _applyArgs(template, args);
  }

  String translateSafe(String key, {Map<String, Object>? args}) {
    final templateInLocale = _localizedStrings[key];
    if (templateInLocale != null) {
      return _applyArgs(templateInLocale, args);
    }

    final templateInEnglish = _englishStrings[key];
    if (templateInEnglish != null) {
      return _applyArgs(templateInEnglish, args);
    }

    // English missing as well -> return the key itself.
    return _applyArgs(key, args);
  }

  /// Basic plural support using suffixes:
  /// - `{baseKey}_one` for 1
  /// - `{baseKey}_other` for everything else
  /// (Designed for simple production usage; can be expanded later.)
  String translatePlural(
    String baseKey, {
    required int count,
    Map<String, Object>? args,
  }) {
    final suffix = count == 1 ? 'one' : 'other';
    final pluralKey = '${baseKey}_$suffix';
    return translateSafe(pluralKey, args: <String, Object>{
      ...(args ?? const {}),
      'count': count,
    });
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension LocalizationExtension on BuildContext {
  String tr(
    String key, {
    Map<String, Object>? args,
  }) =>
      AppLocalizations.of(this).translateSafe(key, args: args);

  String trSafe(
    String key, {
    Map<String, Object>? args,
  }) =>
      AppLocalizations.of(this).translateSafe(key, args: args);

  String trPlural(
    String baseKey, {
    required int count,
    Map<String, Object>? args,
  }) =>
      AppLocalizations.of(this).translatePlural(
        baseKey,
        count: count,
        args: args,
      );
}
