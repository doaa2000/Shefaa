import 'package:shefaa_app/features/bookings/data/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookingRemoteDatasource {
  Future<void> createBooking({
    required int doctorId,
    required double amount,
    required String paymentMethod,
    required DateTime bookedDate,
    required String session,
    required String startTime,
    required String endTime,
  });

  Future<List<BookingModel>> getMyBookings();

  Future<void> cancelBooking(int bookingId);
}

class BookingRemoteDatasourceImpl implements BookingRemoteDatasource {
  final SupabaseClient supabase;
  BookingRemoteDatasourceImpl(this.supabase);

  @override
  Future<void> createBooking({
    required int doctorId,
    required double amount,
    required String paymentMethod,
    required DateTime bookedDate,
    required String session,
    required String startTime,
    required String endTime,
  }) async {
    final patientId = supabase.auth.currentUser!.id;

    final payment = await supabase
        .from('payments')
        .insert({
          'patient_id': patientId,
          'amount': amount,
          'payment_method': paymentMethod,
          // Cash is collected at the clinic, so nothing has been paid yet.
          // Recording 'paid' here put revenue in the books for patients who had
          // not walked in, and for some who never would.
          'status': 'pending',
        })
        .select('id')
        .single();

    await supabase.from('bookings').insert({
      'patient_id': patientId,
      'doctor_id': doctorId,
      'payment_id': payment['id'],
      'booked_date': _dateOnly(bookedDate),
      'session': session,
      'start_time': startTime,
      'end_time': endTime,
      'status': 'confirmed',
    });
  }

  @override
  Future<List<BookingModel>> getMyBookings() async {
    final rows = await supabase
        .from('bookings')
        .select('''
          id,
          status,
          created_at,
          booked_date,
          session,
          start_time,
          end_time,
          doctor:doctor_id (
            id,
            name,
            image,
            specialization,
            location,
            waiting_time,
            consultation_fee
          ),
          payments (
            id,
            amount,
            payment_method,
            status
          )
        ''')
        .order('booked_date', ascending: false);

    final list = (rows as List).cast<Map<String, dynamic>>();
    final queue = await _queueNumbers(list.map((e) => e['id'] as int).toList());

    return list
        .map((e) => BookingModel.fromMap(e, queueNumber: queue[e['id']]))
        .toList();
  }

  @override
  Future<void> cancelBooking(int bookingId) async {
    await supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }

  /// Queue position lives in the `booking_queue` view, which recomputes it from
  /// the bookings still standing rather than storing a number that would go
  /// stale the moment somebody ahead cancelled.
  ///
  /// A failure here costs the position, not the booking list, so it is
  /// swallowed and the cards simply render without a number.
  Future<Map<int, int>> _queueNumbers(List<int> bookingIds) async {
    if (bookingIds.isEmpty) return const {};
    try {
      final rows = await supabase
          .from('booking_queue')
          .select('booking_id, queue_number')
          .inFilter('booking_id', bookingIds);

      return {
        for (final row in (rows as List).cast<Map<String, dynamic>>())
          row['booking_id'] as int: (row['queue_number'] as num).toInt(),
      };
    } catch (_) {
      return const {};
    }
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
