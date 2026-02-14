import 'package:flutter/material.dart';
import 'package:shefaa_app/core/helper_functions/on_generate_route.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/features/auth/presentation/screens/login_screen.dart';
import 'package:shefaa_app/features/home/presentation/screens/home_screen.dart';
import 'package:shefaa_app/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shefaa App',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      onGenerateRoute: onGenerateRoute,

      locale: const Locale('ar'),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
      ),
      home: LoginScreen(),
    );
  }
}
