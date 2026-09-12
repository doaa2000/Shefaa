import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/helper_functions/on_generate_route.dart';
import 'package:shefaa_app/core/services/custom_bloc_observer.dart';
import 'package:shefaa_app/core/services/secure_storage_service.dart';
import 'package:shefaa_app/core/services/selected_city_service.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_config.dart';
import 'package:shefaa_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shefaa_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:shefaa_app/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

  
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    Bloc.observer = CustomBlocObserver();

  AppConfig.assertConfigured();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  // Read before the first frame so no screen has to wait on it, and the app
  // bar never flashes "all cities" over a city the patient already picked.
  final selectedCityService = SelectedCityService();
  await selectedCityService.load();

  setupServiceLocator(selectedCityService);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<dynamic>? _authSubscription;

  /// The auth stream replays its last event to a new listener, so the first
  /// thing we hear is whatever Supabase restored at startup. The splash screen
  /// owns that decision -- and may still recover a session from our own refresh
  /// token -- so this must not act on it, least of all by clearing the tokens
  /// the splash is about to try.
  var _sawStartupEvent = false;

  @override
  void initState() {
    super.initState();

    // When the session goes away while the app is open -- signed out, or a
    // refresh token that no longer works -- every query silently starts coming
    // back empty, because row level security answers `anon` with zero rows
    // instead of an error. Leave the signed-in screens rather than let the
    // patient stare at a home screen with no doctors on it.
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!_sawStartupEvent) {
        _sawStartupEvent = true;
        return;
      }

      if (data.session != null) return;

      unawaited(getIt<SecureStorageService>().clearTokens());

      final navigator = _navigatorKey.currentState;
      if (navigator == null || _isOnLogin(navigator)) return;

      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    });
  }

  /// Logging out navigates on its own, from the button the patient pressed.
  /// This guard is for the sessions that end without anyone asking, so it must
  /// not push a second login screen on top of the first.
  ///
  /// popUntil with a predicate that is true straight away pops nothing -- it is
  /// how a NavigatorState is asked which route is on top.
  bool _isOnLogin(NavigatorState navigator) {
    var onLogin = false;
    navigator.popUntil((route) {
      onLogin = route.settings.name == AppRoutes.login;
      return true;
    });
    return onLogin;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
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
        home: SplashScreen(),
      ),
    );
  }
}
