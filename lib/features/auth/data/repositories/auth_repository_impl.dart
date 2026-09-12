import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';
import 'package:shefaa_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl(this.authRemoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await authRemoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(_message(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    String? birthDate,
    String? gender,
    required String name,
    required String phone,
  }) async {
    try {
      final user = await authRemoteDataSource.register(
        email: email,
        password: password,
        birthDate: birthDate,
        gender: gender,
        name: name,
        phone: phone,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(_message(e)));
    }
  }

    @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await authRemoteDataSource.logout();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(_message(e)));
    }
  }

  /// What the patient reads when signing in or up fails.
  ///
  /// Supabase raises in English and stringifies as
  /// `AuthApiException(message: Email not confirmed, statusCode: 400)`. These
  /// are the three a patient can actually cause -- and the first one stops
  /// being rare the moment email confirmation is switched on, which is the
  /// point of the change this arrived with.
  static String _message(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains('email not confirmed')) {
        return 'لم يتم تأكيد بريدك الإلكتروني بعد. يرجى فتح رسالة التأكيد أولاً';
      }
      if (message.contains('invalid login credentials')) {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      }
      if (message.contains('already registered') ||
          message.contains('already been registered')) {
        return 'هذا البريد الإلكتروني مسجل بالفعل. يرجى تسجيل الدخول';
      }
      return error.message;
    }

    return error.toString();
  }
}
