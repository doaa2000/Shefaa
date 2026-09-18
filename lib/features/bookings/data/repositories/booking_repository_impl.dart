import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/bookings/data/datasources/bookings_remote_datasource.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/bookings/domain/entites/pending_review.dart';
import 'package:shefaa_app/features/bookings/domain/repositories/booking_repository.dart';
import 'package:shefaa_app/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDatasource remoteDatasource;

  BookingRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, int>> createBooking({
    required int doctorId,
    required String paymentMethod,
    required DateTime bookedDate,
    required String session,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final bookingId = await remoteDatasource.createBooking(
        doctorId: doctorId,
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

  @override
  Future<Either<Failure, void>> reportAbsence(int bookingId) async {
    try {
      await remoteDatasource.reportAbsence(bookingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_message(e)));
    }
  }

  @override
  Future<Either<Failure, void>> rateBooking({
    required int bookingId,
    required int stars,
    String? comment,
  }) async {
    try {
      await remoteDatasource.rateBooking(
        bookingId: bookingId,
        stars: stars,
        comment: comment,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_message(e)));
    }
  }

  @override
  Future<Either<Failure, PendingReviewEntity?>> pendingReview() async {
    try {
      return Right(await remoteDatasource.pendingReview());
    } catch (e) {
      return Left(ServerFailure(_message(e)));
    }
  }

  /// What the patient is actually shown when a booking is refused.
  ///
  /// The database raises in English and tags each refusal with a `hint`. The
  /// hint is the contract -- a short, stable token -- and the wording now comes
  /// from the app's own strings, so a refusal is read in whichever language the
  /// patient set. It used to be an Arabic literal on this line, which was one
  /// language the database was right not to hold and the app was wrong to.
  static String _byHint(String hint) {
    switch (hint) {
      case 'invalid_stars':
        return S.current.booking_error_invalid_stars;
      case 'comment_too_long':
        return S.current.booking_error_comment_too_long;
      case 'cancelled_not_rateable':
        return S.current.booking_error_cancelled_not_rateable;
      case 'absent_not_rateable':
        return S.current.booking_error_absent_not_rateable;
      case 'appointment_not_yet':
        return S.current.booking_error_appointment_not_yet;
      case 'session_full':
        return S.current.booking_error_session_full;
      case 'session_not_offered':
        return S.current.booking_error_session_not_offered;
      case 'already_booked':
        return S.current.booking_error_already_booked;
      case 'not_signed_in':
        return S.current.booking_error_not_signed_in;
      case 'booking_immutable':
        return S.current.booking_error_booking_immutable;
      case 'cancel_only':
        return S.current.booking_error_cancel_only;
      // True whether cancelling closes at the appointment, as it does now, or
      // some period before it, which is one settings row away.
      case 'cancellation_closed':
        return S.current.booking_error_cancellation_closed;
      case 'time_has_passed':
        return S.current.booking_error_time_has_passed;
      case 'date_in_past':
        return S.current.booking_error_date_in_past;
      case 'beyond_horizon':
        return S.current.booking_error_beyond_horizon;
      case 'booking_not_found':
        return S.current.booking_error_booking_not_found;
      case 'already_cancelled':
        return S.current.booking_error_already_cancelled;
      case 'cancel_instead':
        return S.current.booking_error_cancel_instead;
      case 'appointment_passed':
        return S.current.booking_error_appointment_passed;
    }
    return '';
  }

  static String _message(Object error) {
    if (error is PostgrestException) {
      final byHint = _byHint(error.hint ?? '');
      if (byHint.isNotEmpty) return byHint;

      // Constraints the database enforces without a hint of their own.
      if (error.message.contains('bookings_one_place_per_session')) {
        return _byHint('already_booked');
      }
      if (error.message.contains('violates row-level security')) {
        return S.current.booking_error_not_allowed;
      }

      // Anything else is Postgres talking to itself. Saying so is more use
      // than a soothing sentence that hides which call failed.
      return error.message;
    }

    return error.toString();
  }
}
