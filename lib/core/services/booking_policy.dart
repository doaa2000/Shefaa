import 'package:supabase_flutter/supabase_flutter.dart';

/// The clinic-wide rules a booking is held to, as the database states them.
///
/// Only one so far: how long before their window a patient may still cancel.
/// It is read from platform_settings rather than written here, because the
/// database is what enforces it -- a copy in the app that drifted would show a
/// deadline the server does not honour, which is worse than showing none.
///
/// The default stands in until the first read comes back, and after one that
/// fails. Getting it slightly wrong offline costs a button shown a few minutes
/// too long; the server still refuses.
class BookingPolicy {
  BookingPolicy._();

  static final BookingPolicy instance = BookingPolicy._();

  Duration _cancellationNotice = const Duration(hours: 1);

  Duration get cancellationNotice => _cancellationNotice;

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
