import 'package:chat_app_flutter/core/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = LanguageConstants.english;

  Locale get locale => _locale;

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(LanguageConstants.localePreferenceKey);
    if (savedLanguageCode == null || savedLanguageCode.isEmpty) {
      _locale = LanguageConstants.english;
      return;
    }
    _locale = Locale(savedLanguageCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LanguageConstants.localePreferenceKey, languageCode);
  }
}
