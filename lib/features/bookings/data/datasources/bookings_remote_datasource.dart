import 'package:shefaa_app/features/bookings/data/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookingRemoteDatasource {
  /// Returns the id of the booking that was created.
  Future<int> createBooking({
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
  Future<int> createBooking({
    required int doctorId,
    required double amount,
    required String paymentMethod,
    required DateTime bookedDate,
    required String session,
    required String startTime,
    required String endTime,
  }) async {
    // One call, one transaction. Two separate inserts meant that when the
    // booking was refused -- a full appointment is an ordinary outcome now --
    // the payment row from the first insert stayed behind, and a patient is not
    // allowed to delete it. create_booking writes both or neither.
    final rows = await supabase.rpc(
      'create_booking',
      params: {
        'p_doctor': doctorId,
        'p_date': _dateOnly(bookedDate),
        'p_session': session,
        'p_start': startTime,
        'p_end': endTime,
        'p_amount': amount,
        'p_method': paymentMethod,
      },
    );

    // A set-returning function comes back as a list of rows.
    final row = (rows as List).cast<Map<String, dynamic>>().first;
    return (row['booking_id'] as num).toInt();
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

    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(BookingModel.fromMap)
        .toList();
  }

  @override
  Future<void> cancelBooking(int bookingId) async {
    await supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
