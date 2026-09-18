import 'package:shefaa_app/features/doctor_availability/data/models/doctor_details_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DoctorAvailabilityRemoteDatasource {
  Future<DoctorDetailsModel> getDoctorAvailability(int doctorId, DateTime date);
}

class DoctorAvailabilityRemoteDatasourceImpl
    implements DoctorAvailabilityRemoteDatasource {
  final SupabaseClient supabase;

  DoctorAvailabilityRemoteDatasourceImpl(this.supabase);

  @override
  Future<DoctorDetailsModel> getDoctorAvailability(
    int doctorId,
    DateTime date,
  ) async {
    // Date only: the function keys off the weekday, and a timezone-shifted
    // timestamp would land on the wrong day.
    final formattedDate = _dateOnly(date);

    // Availability is no longer rows to be read: it is computed from the
    // doctor's weekly schedule, minus bookings already taken, minus any
    // exception for this date. Hence two calls rather than one nested select.
    final results = await Future.wait<dynamic>([
      supabase
          .from('doctors_public')
          .select(
            'id, name, specialization, image, consultation_fee, rating, '
            'specialty_id, clinic_id, waiting_time, location, title',
          )
          .eq('id', doctorId)
          .single(),
      supabase.rpc(
        'doctor_sessions_on',
        params: {
          'p_doctor': doctorId,
          'p_date': formattedDate,
          // Asked for, not assumed. The same function answers the capacity
          // check behind every booking -- including the doctor marking this
          // morning's appointment finished -- and that one needs the day as
          // the schedule describes it, hours gone included. This screen is
          // offering places, so it asks for the ones still to come.
          'p_from_now': true,
        },
      ),
    ]);

    return DoctorDetailsModel.fromParts(
      doctorRow: results[0] as Map<String, dynamic>,
      sessionRows: (results[1] as List?) ?? const [],
    );
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
