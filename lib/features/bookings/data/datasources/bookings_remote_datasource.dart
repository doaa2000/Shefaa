import 'package:shefaa_app/core/services/booking_policy.dart';
import 'package:shefaa_app/features/bookings/data/models/booking_model.dart';
import 'package:shefaa_app/features/bookings/domain/entites/pending_review.dart';
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

  /// Tells the doctor the patient will not be coming, once cancelling has
  /// closed. It does not cancel: the deadline has passed, and letting it
  /// would make the deadline mean nothing.
  Future<void> reportAbsence(int bookingId);

  /// Rates a visit, or replaces the rating already on it. One review per
  /// booking, so there is no separate "edit".
  Future<void> rateBooking({
    required int bookingId,
    required int stars,
    String? comment,
  });

  /// The one visit worth asking about, or null. Null is the ordinary answer.
  Future<PendingReviewEntity?> pendingReview();
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
          absence_reported_at,
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

    // The patient's own reviews for these bookings. A separate read for the
    // same reason the doctor is one: doctor_reviews has its own policy, and an
    // embed a policy refuses comes back null rather than failing.
    final bookingIds = rows.map((row) => row['id']).whereType<Object>().toList();

    final reviews = (await supabase
            .from('doctor_reviews')
            .select('booking_id, stars, comment')
            .inFilter('booking_id', bookingIds) as List)
        .cast<Map<String, dynamic>>();

    final reviewByBooking = {
      for (final review in reviews) review['booking_id']: review,
    };

    return rows
        .where((row) => byId.containsKey(row['doctor_id']))
        .map((row) => BookingModel.fromMap({
              ...row,
              'doctor': byId[row['doctor_id']],
              'review_stars': reviewByBooking[row['id']]?['stars'],
              'review_comment': reviewByBooking[row['id']]?['comment'],
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

  @override
  Future<void> reportAbsence(int bookingId) async {
    // A function rather than a column write: it has to check the window,
    // drop the reminders and tell the doctor, and none of that is the
    // patient's to be trusted with.
    await supabase.rpc('report_absence', params: {'p_booking': bookingId});
  }

  @override
  Future<void> rateBooking({
    required int bookingId,
    required int stars,
    String? comment,
  }) async {
    // A function rather than an insert: it has to prove the appointment
    // belongs to this patient and actually happened, and neither is the
    // client's to assert.
    await supabase.rpc('rate_booking', params: {
      'p_booking': bookingId,
      'p_stars': stars,
      'p_comment': comment,
    });
  }

  @override
  Future<PendingReviewEntity?> pendingReview() async {
    final row = await supabase.rpc('pending_review');
    if (row == null) return null;
    return PendingReviewEntity.fromMap(row as Map<String, dynamic>);
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
