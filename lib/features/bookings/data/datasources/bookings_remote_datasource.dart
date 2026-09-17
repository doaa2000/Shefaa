import 'package:shefaa_app/core/services/booking_policy.dart';
import 'package:shefaa_app/features/bookings/data/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookingRemoteDatasource {
  /// Returns the id of the booking that was created.
  Future<int> createBooking({
    required int doctorId,
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
        // No amount: the fee is the doctor's, and create_booking reads it from
        // Doctors.consultation_fee. Sending it from here meant a booking could
        // be made at any price the client chose.
        'p_method': paymentMethod,
      },
    );

    // A set-returning function comes back as a list of rows.
    final row = (rows as List).cast<Map<String, dynamic>>().first;
    return (row['booking_id'] as num).toInt();
  }

  @override
  Future<List<BookingModel>> getMyBookings() async {
    // Refreshed with the list rather than at launch: the deadline shown next
    // to a booking has to be the one the database will hold the patient to.
    await BookingPolicy.instance.refresh(supabase);

    // The doctor used to be an embedded select on the Doctors table. It is
    // not embedded any more because that table is no longer readable by a
    // patient -- it carries contact details -- and an embed the policy
    // refuses comes back null rather than failing, which would have emptied
    // every booking in this list of the doctor it is with.
    final rows = (await supabase
            .from('bookings')
            .select('''
          id,
          status,
          created_at,
          booked_date,
          session,
          start_time,
          end_time,
          doctor_id,
          payments (
            id,
            amount,
            payment_method,
            status
          )
        ''')
            .order('booked_date', ascending: false) as List)
        .cast<Map<String, dynamic>>();

    if (rows.isEmpty) return const [];

    // One more round trip, not one per booking: a patient with a year of
    // history has seen a handful of doctors, so this is a short list.
    final doctorIds = rows
        .map((row) => row['doctor_id'])
        .whereType<Object>()
        .toSet()
        .toList();

    final doctors = (await supabase
            .from('doctors_public')
            .select(
              'id, name, image, specialization, location, waiting_time, '
              'consultation_fee',
            )
            .inFilter('id', doctorIds) as List)
        .cast<Map<String, dynamic>>();

    final byId = {for (final doctor in doctors) doctor['id']: doctor};

    return rows
        .where((row) => byId.containsKey(row['doctor_id']))
        .map((row) => BookingModel.fromMap({
              ...row,
              'doctor': byId[row['doctor_id']],
            }))
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
