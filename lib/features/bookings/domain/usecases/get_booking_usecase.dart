import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/bookings/domain/repositories/booking_repository.dart';

class GetMyBookingsUsecase
    extends BaseUsecase<List<BookingEntity>, NoParameters> {
  final BookingRepository repository;
  GetMyBookingsUsecase(this.repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(NoParameters params) async {
    return await repository.getMyBookings();
  }
}