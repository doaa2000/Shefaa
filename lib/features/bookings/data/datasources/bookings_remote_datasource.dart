import 'package:shefaa_app/features/bookings/data/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookingRemoteDatasource {
  Future<void> createBooking({
    required String doctorId,
  required double amount,
  required String paymentMethod,
  required DateTime bookedDate,
  required String startTime,
  required String endTime,
  });

  Future<List<BookingModel>> getMyBookings();
}

class BookingRemoteDatasourceImpl implements BookingRemoteDatasource {
  final SupabaseClient supabase;
  BookingRemoteDatasourceImpl(this.supabase);

@override
Future<void> createBooking({
  required String doctorId,
  required double amount,
  required String paymentMethod,
 required DateTime bookedDate,
  required String startTime,
  required String endTime,
}) async {

  // 1. Create payment
  final payment = await supabase
      .from('payments')
      .insert({
        'patient_id': supabase.auth.currentUser!.id,
        'amount': amount,
        'payment_method': paymentMethod,
        'status': 'paid',
      })
      .select('id')
      .single();

  // 2. Create booking
  await supabase.from('bookings').insert({
    'patient_id': supabase.auth.currentUser!.id,
    'doctor_id': doctorId,
    'payment_id': payment['id'],
    'booked_date': bookedDate.toIso8601String(),
    'start_time': startTime,
    'end_time': endTime,
    'status': 'confirmed',
  });
}
@override
Future<List<BookingModel>> getMyBookings() async {
  final res = await supabase
      .from('bookings')
      .select('''
        id,
        status,
        created_at,
        booked_date,
        start_time,
        end_time,
        doctor:doctor_id (
          id,
          name,
          image,
          specialization,
          location,
          waiting_time
        ),
        payments (
          id,
          amount,
          payment_method,
          status
        )
      ''')
      .order('booked_date', ascending: false);

  return (res as List)
      .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
      .toList();
}
}