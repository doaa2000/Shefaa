import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/bookings/data/datasources/bookings_remote_datasource.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/bookings/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDatasource remoteDatasource;

  BookingRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, void>> createBooking({
    required int doctorId,
    required double amount,
    required String paymentMethod,
    required DateTime bookedDate,
    required String session,
    required String startTime,
    required String endTime,
  }) async {
    try {
      await remoteDatasource.createBooking(
        doctorId: doctorId,
        amount: amount,
        paymentMethod: paymentMethod,
        bookedDate: bookedDate,
        session: session,
        startTime: startTime,
        endTime: endTime,
      );
      return const Right(null);
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

  /// The two constraint violations a patient can actually cause, said in words
  /// they can act on instead of the raw Postgres text.
  static String _message(Object error) {
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
