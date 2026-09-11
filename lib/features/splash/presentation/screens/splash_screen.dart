import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shefaa_app/core/services/secure_storage_service.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorageService secureStorage =
      GetIt.instance<SecureStorageService>();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final destination = await _resolveDestination();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, destination);
  }

  /// Supabase is the only thing that knows whether we can still reach the
  /// database, so it is what decides.
  ///
  /// This used to open the home screen whenever our own copy of the access
  /// token was non-empty. That copy is not the session: it was never cleared on
  /// logout and never rewritten on register, so it outlived the session it came
  /// from. The app then opened on the home screen with no session behind it,
  /// every query went out as `anon`, and row level security answers `anon` with
  /// zero rows rather than an error -- a home screen with no doctors and a
  /// profile with no name, and nothing on screen to say why.
  Future<String> _resolveDestination() async {
    final auth = Supabase.instance.client.auth;
    var session = auth.currentSession;

    if (session == null) {
      // Supabase restores its own session on startup, but ours may be the only
      // refresh token left (a reinstall, or storage it could not read).
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        session = await _try(() => auth.setSession(refreshToken));
      }
    } else if (session.isExpired) {
      session = await _try(() => auth.refreshSession());
    }

    if (session == null) {
      await secureStorage.clearTokens();
      return AppRoutes.login;
    }

    // Keep our copy in step with the session that actually works.
    final refreshToken = session.refreshToken;
    if (refreshToken != null) {
      await secureStorage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: refreshToken,
      );
    }

    return AppRoutes.home;
  }

  /// A refresh that fails means no session, not a crash on the splash screen:
  /// the device may be offline, or the refresh token revoked by a sign-in
  /// somewhere else.
  Future<Session?> _try(Future<AuthResponse> Function() call) async {
    try {
      return (await call()).session;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
