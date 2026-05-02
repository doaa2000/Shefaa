// create_booking_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/bookings/domain/repositories/booking_repository.dart';

class CreateBookingUsecase
    extends BaseUsecase<void, CreateBookingParams> {
  final BookingRepository repository;
  CreateBookingUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateBookingParams params) async {
    return await repository.createBooking(
      doctorId: params.doctorId,
      amount:         params.amount,
      paymentMethod:  params.paymentMethod,
      bookedDate:     params.bookedDate,
      startTime:      params.startTime,
      endTime:        params.endTime,

    );
  }
}

class CreateBookingParams {
  final String doctorId;
  final double amount;
  final String paymentMethod;
  final DateTime bookedDate;
  final String startTime;
  final String endTime;


  CreateBookingParams({
    required this.doctorId,
    required this.amount,
    required this.paymentMethod,
    required this.bookedDate,
    required this.startTime,
    required this.endTime,
  });
}

