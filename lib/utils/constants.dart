import 'package:flutter/material.dart';
import 'package:chat_app_flutter/core/localization/app_localizations.dart';

class AppConstants {
  //App Info
  static const String appVersion = '1.0.0';

  //ZegoCloud Credentials
  static const int zegoAppID = 1633858212;
  static const String zegoAppSign =
      'def0a19dfa1efaccb44ffe731a391f06021975045ea74e21890cf33da86648a3';

  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFFF6584);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
  );

  static const TextStyle bodyTextSecondary = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
  static const double borderRadiusCircular = 50.0;

  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;

  static const String defaultAvatar =
      'https://ui-avatars.com/api/?background=6C63FF&color=fff&name=';

  static const bool enableVideocall = true;
  static const bool enableVoicecall = true;
  static const bool enableScreenShare = false;
  static const bool enableChat = true;

  String getUserAvatarUrl(String name) {
    return '${AppConstants.defaultAvatar}${Uri.encodeComponent(name)}';
  }

  String formatTimestamp(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return context.trSafe('time_just_now');
        }
        return context.trSafe(
          'time_minutes_ago',
          args: <String, Object>{'count': difference.inMinutes},
        );
      }

      return context.trSafe(
        'time_hours_ago',
        args: <String, Object>{'count': difference.inHours},
      );
    }

    if (difference.inDays == 1) {
      return context.trSafe('time_yesterday');
    }

    if (difference.inDays < 7) {
      return context.trSafe(
        'time_days_ago',
        args: <String, Object>{'count': difference.inDays},
      );
    }

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
