import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/features/bookings/presentation/screens/bookings_screen.dart';
import 'package:shefaa_app/features/home/presentation/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The channel every notification from this app goes through.
///
/// Android groups notifications by channel and lets the patient silence a
/// channel rather than the whole app, so the name is something they will read
/// in the system settings -- which is why it is written the way the rest of
/// the app speaks.
///
/// The id is repeated in AndroidManifest.xml as Firebase's default channel, so
/// that a notification the system draws while the app is closed lands in the
/// same place, with the same importance, as one the app draws itself.
const _channel = AndroidNotificationChannel(
  'appointments',
  'المواعيد',
  description: 'تأكيد الحجز، وإلغاؤه، والتذكير بالموعد',
  importance: Importance.high,
);

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

  /// The app's one navigator, so a tapped notification can open the screen it
  /// is about. Held here rather than handed over after construction: this is
  /// the only thing in the app that has to navigate from outside a widget.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _tapSubscription;

  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Only used for a message that arrived without an id of its own; masked
  /// into a positive 32-bit integer because that is all Android accepts, and
  /// a millisecond timestamp is far too large for it.
  int _nextFallbackId = 0;

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

      await _startDrawingWhileOpen();
      await _startListeningForTaps();
    } catch (error) {
      debugPrint('push: could not start notifications: $error');
    }
  }

  /// Android does not show a notification while the app it belongs to is in
  /// the foreground. It delivers the message to the app instead and leaves the
  /// showing to it -- so a patient who books an appointment and stays on the
  /// screen sees nothing at all, and reasonably concludes that notifications
  /// do not work.
  ///
  /// iOS is not included: it was already told to present notifications in the
  /// foreground itself, and drawing a second one here would show every message
  /// twice.
  Future<void> _startDrawingWhileOpen() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    if (_foregroundSubscription != null) return;

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen(_drawWhileOpen);
  }

  Future<void> _drawWhileOpen(RemoteMessage message) async {
    final notification = message.notification;

    // A message carrying only data is one the app is meant to act on, not to
    // show. Nothing sends those yet, and showing an empty notification would
    // be worse than showing none.
    if (notification == null) return;

    try {
      await _localNotifications.show(
        // Derived from the message so that the same message arriving twice
        // replaces itself rather than stacking.
        id: (message.messageId?.hashCode ?? _nextFallbackId++) & 0x7fffffff,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    } catch (error) {
      debugPrint('push: could not draw the notification: $error');
    }
  }

  /// Where a tapped notification goes.
  ///
  /// Two ways in: the app was in the background and the tap brought it
  /// forward, or the app was not running at all and the tap started it. The
  /// second one is not a stream -- the message is waiting to be asked for.
  ///
  /// A notification tapped while the app is already open is not handled: the
  /// patient is in the app, and yanking them off the screen they are on is
  /// worse than doing nothing.
  Future<void> _startListeningForTaps() async {
    _tapSubscription ??=
        FirebaseMessaging.onMessageOpenedApp.listen(_openWhatItIsAbout);

    final launchedBy = await FirebaseMessaging.instance.getInitialMessage();
    if (launchedBy != null) _openWhatItIsAbout(launchedBy);
  }

  void _openWhatItIsAbout(RemoteMessage message) {
    // Everything this app sends is about a booking. A message without one is
    // either from somewhere else or from a version of this that does not
    // exist yet, and either way the app opens where it always does.
    if (message.data['booking_id'] == null) return;

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    // A request to rate is about a visit that has happened; everything else --
    // a confirmation, a cancellation, a reminder -- is about one that has not.
    final past = message.data['action'] == 'review';

    navigator.pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
      arguments: HomeArgs(
        tab: HomeScreen.bookingsTab,
        bookingsTab:
            past ? BookingsScreen.pastTab : BookingsScreen.upcomingTab,
      ),
    );
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
