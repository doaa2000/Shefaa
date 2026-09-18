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
  final String paymentMethod;
  final DateTime bookedDate;
  final String session;
  final String startTime;
  final String endTime;

  const CreateBookingParams({
    required this.doctorId,
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

class RateBookingUsecase extends BaseUsecase<void, RateBookingParams> {
  final BookingRepository repository;
  RateBookingUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(RateBookingParams params) {
    return repository.rateBooking(
      bookingId: params.bookingId,
      stars: params.stars,
      comment: params.comment,
    );
  }
}

class RateBookingParams {
  final int bookingId;
  final int stars;
  final String? comment;

  const RateBookingParams({
    required this.bookingId,
    required this.stars,
    this.comment,
  });
}

class ReportAbsenceUsecase extends BaseUsecase<void, int> {
  final BookingRepository repository;
  ReportAbsenceUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(int bookingId) {
    return repository.reportAbsence(bookingId);
  }
}
