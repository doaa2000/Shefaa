import 'package:shefaa_app/features/bookings/data/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookingRemoteDatasource {
  /// Returns the place in the queue the booking actually got.
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

/// A booking's place in its session: the patient's own ticket, and the number
/// the doctor is on.
typedef QueuePlace = ({int queueNumber, int? nowServing});

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
    // booking was refused -- a full session is an ordinary outcome now -- the
    // payment row from the first insert stayed behind, and a patient is not
    // allowed to delete it. create_booking writes both or neither, and hands
    // back the place in the queue the booking actually got rather than the
    // number predicted before anyone else had committed.
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
    return (row['queue_number'] as num).toInt();
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

    return list.map((e) {
      final place = queue[e['id']];
      return BookingModel.fromMap(
        e,
        queueNumber: place?.queueNumber,
        nowServing: place?.nowServing,
      );
    }).toList();
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
  /// `now_serving` is the number the doctor is on. The patient cannot work it
  /// out themselves -- row level security hides other people's bookings from
  /// them -- so it comes from the view, which ranks over all of them and
  /// returns only the rows this patient may have.
  ///
  /// A failure here costs the position, not the booking list, so it is
  /// swallowed and the cards simply render without a number.
  Future<Map<int, QueuePlace>> _queueNumbers(List<int> bookingIds) async {
    if (bookingIds.isEmpty) return const {};
    try {
      final rows = await supabase
          .from('booking_queue')
          .select('booking_id, queue_number, now_serving')
          .inFilter('booking_id', bookingIds);

      return {
        for (final row in (rows as List).cast<Map<String, dynamic>>())
          row['booking_id'] as int: (
            queueNumber: (row['queue_number'] as num).toInt(),
            nowServing: (row['now_serving'] as num?)?.toInt(),
          ),
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
