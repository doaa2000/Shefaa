import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shefaa_app/core/services/secure_storage_service.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_consent.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/features/consent/domain/usecases/consent_usecases.dart';
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

    // A session is not the same as permission to be in this app. A doctor who
    // signed in here before the app started refusing them still has a working
    // token on the device, and it would walk straight past the login screen.
    if (!await _isPatientAccount()) {
      await Supabase.instance.client.auth.signOut();
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

    // Patients who registered before the app asked, and anyone whose
    // agreement is to older wording, are asked before they reach anything
    // that would store health data about them.
    if (!await _hasHealthConsent()) return AppRoutes.healthConsent;

    return AppRoutes.home;
  }

  /// Whether this account has accepted the current health-data wording.
  ///
  /// A failure is treated as "yes", for the same reason the account check
  /// above is: a patient offline should not be stopped at a gate by a round
  /// trip that did not come back. They are asked again on the next launch that
  /// does reach the server.
  Future<bool> _hasHealthConsent() async {
    final result = await getIt<HasAcceptedConsentUseCase>()(
      const ConsentParams(
        kind: 'health_data',
        version: AppConsent.healthDataVersion,
      ),
    );
    return result.fold((_) => true, (accepted) => accepted);
  }

  /// Whether the restored session belongs to one of this app's own accounts.
  ///
  /// A failure here is treated as "yes". The check is a tidy-up for a handful
  /// of accounts, and the alternative -- a patient offline on a plane being
  /// shown the login screen because a round trip did not come back -- is worse
  /// than the thing it guards against.
  Future<bool> _isPatientAccount() async {
    try {
      final allowed =
          await Supabase.instance.client.rpc('is_patient_account');
      return allowed != false;
    } catch (_) {
      return true;
    }
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
