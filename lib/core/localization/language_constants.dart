import 'package:flutter/material.dart';

class LanguageConstants {
  static const String localePreferenceKey = 'selected_locale';
  static const Locale english = Locale('en');
  static const Locale hindi = Locale('hi');

  static const List<Locale> supportedLocales = <Locale>[english, hindi];
}
