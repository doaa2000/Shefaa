import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/bookings/domain/repositories/booking_repository.dart';

class CreateBookingUsecase extends BaseUsecase<int, CreateBookingParams> {
  final BookingRepository repository;
  CreateBookingUsecase(this.repository);

  @override
  Future<Either<Failure, int>> call(CreateBookingParams params) {
    return repository.createBooking(
      doctorId: params.doctorId,
      amount: params.amount,
      paymentMethod: params.paymentMethod,
      bookedDate: params.bookedDate,
      session: params.session,
      startTime: params.startTime,
      endTime: params.endTime,
    );
  }
}

class CreateBookingParams {
  final int doctorId;
  final double amount;
  final String paymentMethod;
  final DateTime bookedDate;
  final String session;
  final String startTime;
  final String endTime;

  const CreateBookingParams({
    required this.doctorId,
    required this.amount,
    required this.paymentMethod,
    required this.bookedDate,
    required this.session,
    required this.startTime,
    required this.endTime,
  });
}

class CancelBookingUsecase extends BaseUsecase<void, int> {
  final BookingRepository repository;
  CancelBookingUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(int bookingId) {
    return repository.cancelBooking(bookingId);
  }
}
