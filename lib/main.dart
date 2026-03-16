import 'package:chat_app_flutter/firebase_options.dart';
import 'package:chat_app_flutter/screens/splash_screen.dart';
import 'package:chat_app_flutter/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: _buildTheme(),
      home: SplashScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        color: AppConstants.cardColor,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: BorderSide(color: AppConstants.primaryColor, width: 2),
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingMedium,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondaryColor,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        showUnselectedLabels: true,
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        elevation: 8,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants.primaryColor,
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppConstants.primaryColor,
      ),

      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(color: AppConstants.textSecondaryColor),

      textTheme: TextTheme(
        displayLarge: AppConstants.heading1,
        displayMedium: AppConstants.heading1.copyWith(fontSize: 24),
        bodyLarge: AppConstants.bodyText,
        bodyMedium: AppConstants.bodyTextSecondary,
      ),

      useMaterial3: true,
    );
  }
}
