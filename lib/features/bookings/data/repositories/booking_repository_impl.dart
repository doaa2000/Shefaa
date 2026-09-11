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
      final queueNumber = await remoteDatasource.createBooking(
        doctorId: doctorId,
        amount: amount,
        paymentMethod: paymentMethod,
        bookedDate: bookedDate,
        session: session,
        startTime: startTime,
        endTime: endTime,
      );
      return Right(queueNumber);
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
  /// create_booking and the capacity trigger raise messages already written
  /// for a patient to read, so those are passed through as they are. The rest
  /// is Postgres talking to itself, and only the cases a patient can cause are
  /// worth translating; anything else would be a lie dressed as an apology.
  static String _message(Object error) {
    if (error is PostgrestException) {
      final message = error.message;
      if (message.contains('bookings_one_place_per_session')) {
        return 'لديك حجز بالفعل في هذه الفترة';
      }
      if (message.contains('violates row-level security')) {
        return 'لا تملك صلاحية تنفيذ هذا الإجراء';
      }
      return message;
    }

    final raw = error.toString();
    if (raw.contains('bookings_one_place_per_session')) {
      return 'لديك حجز بالفعل في هذه الفترة';
    }
    if (raw.contains('violates row-level security')) {
      return 'لا تملك صلاحية تنفيذ هذا الإجراء';
    }
    return raw;
  }
}
