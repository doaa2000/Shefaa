import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';

abstract class BookingRepository {
  Future<Either<Failure, void>> createBooking({
    required String doctorId,
    required double amount,
    required String paymentMethod,
    required String startTime,
    required String endTime,
    required DateTime bookedDate,
  });

  Future<Either<Failure, List<BookingEntity>>> getMyBookings();
}