// lib/main.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'screens/home_page.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize database
  await DatabaseHelper.instance.database;
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    // Apply system overlay style based on theme brightness
    SystemChrome.setSystemUIOverlayStyle(
      themeData.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: themeData.backgroundColor,
              systemNavigationBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: themeData.backgroundColor,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
    );
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Buddy',
      theme: ThemeData(
        brightness: themeData.brightness,
        primaryColor: themeData.primaryColor,
        scaffoldBackgroundColor: themeData.backgroundColor,
        cardColor: themeData.cardColor,
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: themeData.textColor,
          ),
        ),
        // Apply the theme to Cupertino widgets
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: themeData.brightness,
          primaryColor: themeData.primaryColor,
          scaffoldBackgroundColor: themeData.backgroundColor,
          barBackgroundColor: themeData.cardColor,
          textTheme: CupertinoTextThemeData(
            primaryColor: themeData.primaryColor,
            textStyle: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 17,
              color: themeData.textColor,
            ),
          ),
        ),
      ),
      home: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: themeData.brightness,
          primaryColor: themeData.primaryColor,
          scaffoldBackgroundColor: themeData.backgroundColor,
          barBackgroundColor: themeData.cardColor,
          textTheme: CupertinoTextThemeData(
            primaryColor: themeData.primaryColor,
            textStyle: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 17,
              color: themeData.textColor,
            ),
          ),
        ),
        child: HomePage(),
      ),
      localizationsDelegates: [
        DefaultCupertinoLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
      ],
    );
  }
}