import 'dart:convert';

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
      final text = _plainText(error.message);
      final lower = text.toLowerCase();

      if (lower.contains('email not confirmed')) {
        return 'لم يتم تأكيد بريدك الإلكتروني بعد. يرجى فتح رسالة التأكيد أولاً';
      }
      if (lower.contains('invalid login credentials')) {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      }
      if (lower.contains('already registered') ||
          lower.contains('already been registered')) {
        return 'هذا البريد الإلكتروني مسجل بالفعل. يرجى تسجيل الدخول';
      }
      // The mail service is not reachable or not configured. Nothing the
      // patient did, and nothing they can do about it either -- so it says so
      // plainly instead of blaming their address.
      if (lower.contains('error sending') ||
          lower.contains('error confirmation') ||
          lower.contains('smtp')) {
        return 'تعذر إرسال رسالة التأكيد حالياً. يرجى المحاولة بعد قليل';
      }
      if (lower.contains('rate limit') || lower.contains('too many requests')) {
        return 'محاولات كثيرة في وقت قصير. يرجى الانتظار قليلاً ثم المحاولة';
      }

      return text;
    }

    return error.toString();
  }

  /// Supabase sometimes puts a JSON body in `message`, so the field reads
  /// `{"code":"unexpected_failure","message":"Error sending confirmation
  /// email"}`. The sentence worth showing is inside it, and a patient must
  /// never be handed the envelope.
  static String _plainText(String message) {
    final trimmed = message.trim();
    if (!trimmed.startsWith('{')) return trimmed;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map && decoded['message'] is String) {
        return (decoded['message'] as String).trim();
      }
    } catch (_) {
      // Not JSON after all; the raw text is still better than nothing.
    }
    return trimmed;
  }
}
