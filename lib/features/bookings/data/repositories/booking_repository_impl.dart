import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/bookings/data/datasources/bookings_remote_datasource.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/bookings/domain/repositories/booking_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDatasource remoteDatasource;

  BookingRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, int>> createBooking({
    required int doctorId,
    required double amount,
    required String paymentMethod,
    required DateTime bookedDate,
    required String session,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final bookingId = await remoteDatasource.createBooking(
        doctorId: doctorId,
        amount: amount,
        paymentMethod: paymentMethod,
        bookedDate: bookedDate,
        session: session,
        startTime: startTime,
        endTime: endTime,
      );
      return Right(bookingId);
    } catch (e) {
      return Left(ServerFailure(_message(e)));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getMyBookings() async {
    try {
      return Right(await remoteDatasource.getMyBookings());
    } catch (e) {
      return Left(ServerFailure(_message(e)));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(int bookingId) async {
    try {
      await remoteDatasource.cancelBooking(bookingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_message(e)));
    }
  }

  /// What the patient is actually shown when a booking is refused.
  ///
  /// The database raises in English and tags each refusal with a `hint`. The
  /// hint is the contract -- a short, stable token -- and the Arabic lives
  /// here, in the app that has an Arabic-speaking audience. A database that
  /// held one app's wording would be wrong for the dashboard, which is in
  /// English, and wrong again for the next language either of them gains.
  static const Map<String, String> _byHint = {
    'session_full': 'اكتمل عدد هذه الفترة. يرجى اختيار فترة أخرى',
    'session_not_offered': 'الطبيب لا يعمل في هذه الفترة في هذا اليوم',
    'already_booked': 'لديك حجز بالفعل في هذه الفترة',
    'not_signed_in': 'يرجى تسجيل الدخول أولاً',
    'booking_immutable': 'لا يمكن نقل الحجز. يرجى إلغاؤه والحجز من جديد',
    'cancel_only': 'إلغاء الحجز هو التغيير الوحيد المتاح',
  };

  static String _message(Object error) {
    if (error is PostgrestException) {
      final byHint = _byHint[error.hint];
      if (byHint != null) return byHint;

      // Constraints the database enforces without a hint of their own.
      if (error.message.contains('bookings_one_place_per_session')) {
        return _byHint['already_booked']!;
      }
      if (error.message.contains('violates row-level security')) {
        return 'لا تملك صلاحية تنفيذ هذا الإجراء';
      }

      // Anything else is Postgres talking to itself. Saying so is more use
      // than a soothing sentence that hides which call failed.
      return error.message;
    }

    return error.toString();
  }
}
