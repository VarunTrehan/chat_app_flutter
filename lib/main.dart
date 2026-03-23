import 'package:chat_app_flutter/core/localization/app_localizations.dart';
import 'package:chat_app_flutter/core/localization/language_constants.dart';
import 'package:chat_app_flutter/core/providers/language_provider.dart';
import 'package:chat_app_flutter/core/providers/theme_provider.dart';
import 'package:chat_app_flutter/core/theme/app_theme.dart';
import 'package:chat_app_flutter/firebase_options.dart';
import 'package:chat_app_flutter/screens/splash_screen.dart';
import 'package:chat_app_flutter/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  ZIMKit().init(
    appID: AppConstants.zegoAppID,
    appSign: AppConstants.zegoAppSign,
  );

  final navigatorKey = GlobalKey<NavigatorState>();

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  ZegoUIKit().initLog().then((_) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([
      ZegoUIKitSignalingPlugin(),
    ]);
  });

  final themeProvider = ThemeProvider();
  final languageProvider = LanguageProvider();
  await Future.wait([
    themeProvider.loadSavedTheme(),
    languageProvider.loadSavedLanguage(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
      ],
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppThemeData.light,
      darkTheme: AppThemeData.dark,
      themeMode: themeProvider.themeMode,
      locale: languageProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageConstants.supportedLocales,
      home: SplashScreen(),
    );
  }
}
