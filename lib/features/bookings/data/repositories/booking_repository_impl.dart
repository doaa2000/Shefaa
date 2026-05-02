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
    required String doctorId,
  required double amount,
  required String paymentMethod,
  required DateTime bookedDate,
  required String startTime,
  required String endTime,
  }) async {
    try {
      await remoteDatasource.createBooking(
        doctorId: doctorId,
        amount:         amount,
        paymentMethod:  paymentMethod,
        bookedDate:     bookedDate,
        startTime:      startTime,
        endTime:          endTime,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getMyBookings() async {
    try {
      final bookings = await remoteDatasource.getMyBookings();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
