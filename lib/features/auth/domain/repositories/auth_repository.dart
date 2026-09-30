import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/features/auth/domain/entities/phone_verification.dart';
import 'package:yalla_5roga/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String phone,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String phone,
    required String password,
  });

  Future<Either<Failure, User>> getCachedUser();

  Future<Either<Failure, User>> saveUser(User user);

  Future<Either<Failure, void>> logout();

  bool get hasFirebaseSession;

  Future<Either<Failure, PhoneVerification>> sendOtp({
    required String phone,
    int? forceResendingToken,
  });

  /// Verifies SMS OTP, optionally updates display name, caches [User], returns it.
  Future<Either<Failure, User>> verifyOtpAndCache({
    required String verificationId,
    required String smsCode,
    required String phone,
    String? name,
  });

  Future<Either<Failure, String?>> idToken();

  Future<Either<Failure, void>> signOutFirebase();
}
