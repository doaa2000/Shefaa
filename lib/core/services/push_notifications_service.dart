import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Keeps this installation's Firebase token in step with whoever is signed in.
///
/// Firebase addresses a message to a token, not to a person, so nothing can be
/// sent to a patient until the server knows which tokens are theirs. That is
/// this class's whole job: ask for permission, collect the token, tell the
/// server, and take it back when they sign out.
///
/// Nothing here is allowed to break the app. A patient who refuses
/// notifications, or has no signal at the moment they sign in, must still be
/// able to book an appointment -- so every failure is swallowed after being
/// logged, and the worst outcome is a missed reminder.
class PushNotificationsService {
  PushNotificationsService(this._supabase);

  final SupabaseClient _supabase;

  StreamSubscription<String>? _tokenRefreshSubscription;

  /// The token the server is known to hold for this account. Kept so a repeat
  /// call costs nothing, and so signing out knows what to withdraw.
  String? _registeredToken;

  Future<void>? _inFlight;

  /// Called for every session that appears -- one restored at startup, or one
  /// that has just been signed into.
  ///
  /// Supabase also republishes the session each time it refreshes its access
  /// token, roughly hourly, so this runs far more often than a patient signs
  /// in. It is written to be cheap on the repeat: one guard against two runs
  /// overlapping, and another against re-sending a token the server already
  /// has.
  Future<void> start() {
    return _inFlight ??= _start().whenComplete(() => _inFlight = null);
  }

  Future<void> _start() async {
    try {
      // Asked at the first session, which for a returning patient means the
      // moment the app opens. That is the simple placing, not the best one:
      // a prompt that arrives before the patient has seen anything worth
      // being notified about is a prompt that gets refused, and on iOS a
      // refusal cannot be asked again from inside the app. Worth moving
      // behind the first booking once the reminders themselves exist.
      final settings = await FirebaseMessaging.instance.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        // Withdraw rather than simply stop. Permission can be taken away in
        // the system settings long after it was given, and a token left behind
        // is a message the sender keeps paying to deliver into a closed door.
        await _forget();
        return;
      }

      // iOS hides a notification that arrives while the app is open unless it
      // is asked not to. Android decides this per notification on the sending
      // side, so there is nothing to set here for it.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await FirebaseMessaging.instance.getToken();

      // Null on iOS when APNs has not answered yet. Not an error, and not
      // worth retrying by hand: the refresh stream below delivers it as soon
      // as it exists.
      if (token != null) await _register(token);

      _tokenRefreshSubscription ??=
          FirebaseMessaging.instance.onTokenRefresh.listen(_register);
    } catch (error) {
      debugPrint('push: could not start notifications: $error');
    }
  }

  /// Must run *before* signing out, never after.
  ///
  /// The database function drops the row belonging to the caller, and a moment
  /// after sign-out there is no caller -- the delete would match nothing and
  /// the phone would go on receiving the appointments of an account that is no
  /// longer on it.
  Future<void> stop() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    await _forget();
  }

  Future<void> _register(String token) async {
    if (token == _registeredToken) return;

    try {
      await _supabase.rpc(
        'register_device_token',
        params: {'p_token': token, 'p_platform': _platform},
      );
      _registeredToken = token;
    } catch (error) {
      debugPrint('push: could not register the token: $error');
    }
  }

  Future<void> _forget() async {
    // Falls back to asking Firebase, because the token this installation holds
    // may have been registered by an earlier run of the app that this object
    // knows nothing about.
    final token = _registeredToken ?? await _currentToken();
    _registeredToken = null;
    if (token == null) return;

    try {
      await _supabase.rpc(
        'unregister_device_token',
        params: {'p_token': token},
      );
    } catch (error) {
      debugPrint('push: could not withdraw the token: $error');
    }
  }

  Future<String?> _currentToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (error) {
      return null;
    }
  }

  /// One of the three values the database's check constraint allows. macOS
  /// counts as iOS here because it is delivered through APNs in the same way.
  String get _platform {
    if (kIsWeb) return 'web';

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 'ios';
      default:
        return 'android';
    }
  }
}
