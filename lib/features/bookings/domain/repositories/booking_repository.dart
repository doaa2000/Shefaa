import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';

abstract class BookingRepository {
  Future<Either<Failure, void>> createBooking({
    required int doctorId,
    required double amount,
    required String paymentMethod,
    required DateTime bookedDate,
    required String session,
    required String startTime,
    required String endTime,
  });

  Future<Either<Failure, List<BookingEntity>>> getMyBookings();

  Future<Either<Failure, void>> cancelBooking(int bookingId);
}
