import 'package:supabase_flutter/supabase_flutter.dart';

/// The clinic-wide rules a booking is held to, as the database states them.
///
/// Two of them: how long before their window a patient may still cancel, and
/// how far ahead they may book at all. Both are read from platform_settings
/// rather than written here, because the database is what enforces them -- a
/// copy in the app that drifted would offer a date the server then refuses,
/// which is worse than offering fewer.
///
/// The default stands in until the first read comes back, and after one that
/// fails. Getting it slightly wrong offline costs a button shown a few minutes
/// too long; the server still refuses.
class BookingPolicy {
  BookingPolicy._();

  static final BookingPolicy instance = BookingPolicy._();

  Duration _cancellationNotice = const Duration(hours: 1);

  /// Matches the database's own default. Standing in with the right answer
  /// means the date strip is correct before the first read comes back, not
  /// merely harmless.
  int _bookingHorizonDays = 7;

  Duration get cancellationNotice => _cancellationNotice;

  /// How many days the date strip should offer, today included.
  int get bookingHorizonDays => _bookingHorizonDays;

  /// The last moment this booking can still be called off.
  ///
  /// The date and time are the clinic's own wall clock. So is the device's, for
  /// every patient this app is for, which is why they are compared directly.
  DateTime deadlineFor({required DateTime bookedDate, required String startTime}) {
    final parts = startTime.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final opens = DateTime(
      bookedDate.year,
      bookedDate.month,
      bookedDate.day,
      hour,
      minute,
    );
    return opens.subtract(_cancellationNotice);
  }

  bool canCancel({required DateTime bookedDate, required String startTime}) {
    return DateTime.now().isBefore(
      deadlineFor(bookedDate: bookedDate, startTime: startTime),
    );
  }

  /// Refreshed whenever the bookings list is loaded: it is one small row, and
  /// the alternative is a deadline that goes stale for a whole session.
  Future<void> refresh(SupabaseClient supabase) async {
    try {
      final row = await supabase
          .from('platform_settings')
          .select('cancellation_notice')
          .eq('id', 1)
          .maybeSingle();

      final raw = row?['cancellation_notice'];
      if (raw is String) {
        final parsed = _parseInterval(raw);
        if (parsed != null) _cancellationNotice = parsed;
      }

      // Through the function rather than reading the interval column: a
      // horizon of days renders as '7 days', which _parseInterval is not for,
      // and the database is a better place to do the arithmetic than a regular
      // expression here would be.
      final days = await supabase.rpc('booking_horizon_days');
      if (days is int && days > 0) _bookingHorizonDays = days;
    } catch (_) {
      // Keep the default. A patient with no signal should still see a booking
      // list, and the server is the one that enforces this anyway.
    }
  }

  /// PostgreSQL renders an interval as 'HH:MM:SS' for anything under a day,
  /// which is every value this setting is ever going to hold.
  static Duration? _parseInterval(String value) {
    final parts = value.split(':');
    if (parts.length != 3) return null;
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    final seconds = double.tryParse(parts[2]);
    if (hours == null || minutes == null || seconds == null) return null;
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds.round(),
    );
  }
}
