import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/exceptions.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/network_info.dart';
import 'package:yalla_5roga/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:yalla_5roga/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yalla_5roga/features/auth/data/datasources/firebase_auth_service.dart';
import 'package:yalla_5roga/features/auth/data/models/user_model.dart';
import 'package:yalla_5roga/features/auth/domain/entities/phone_verification.dart';
import 'package:yalla_5roga/features/auth/domain/entities/user.dart';
import 'package:yalla_5roga/features/auth/domain/repositories/auth_repository.dart';

mixin _AuthFirebaseMixin on AuthRepository {
  FirebaseAuthService get firebaseAuth;
  AuthLocalDataSource get local;

  @override
  bool get hasFirebaseSession => firebaseAuth.currentUser != null;

  @override
  Future<Either<Failure, PhoneVerification>> sendOtp({
    required String phone,
    int? forceResendingToken,
  }) async {
    try {
      final result = await firebaseAuth.sendOtp(
        phone: phone,
        forceResendingToken: forceResendingToken,
      );
      return Right(result);
    } on AuthException catch (error) {
      return Left(AuthFailure(error.message, error.code));
    } catch (_) {
      return const Left(AuthFailure('Phone verification failed'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtpAndCache({
    required String verificationId,
    required String smsCode,
    required String phone,
    String? name,
  }) async {
    try {
      final credential = await firebaseAuth.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure('Verification failed'));
      }

      if (name != null && name.trim().isNotEmpty) {
        await firebaseUser.updateDisplayName(name.trim());
      }

      final token = await firebaseAuth.idToken() ?? '';
      final resolvedName = (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : (firebaseUser.displayName?.trim().isNotEmpty == true
              ? firebaseUser.displayName!.trim()
              : phone);

      final user = UserModel(
        id: firebaseUser.uid,
        name: resolvedName,
        phone: firebaseUser.phoneNumber ?? phone,
        email: firebaseUser.email,
        token: token,
        imageUrl: firebaseUser.photoURL,
      );
      await local.cacheUser(user);
      return Right(user);
    } on AuthException catch (error) {
      return Left(AuthFailure(error.message, error.code));
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (_) {
      return const Left(AuthFailure('Invalid verification code'));
    }
  }

  @override
  Future<Either<Failure, String?>> idToken() async {
    try {
      return Right(await firebaseAuth.idToken());
    } catch (_) {
      return const Left(AuthFailure('Unable to refresh token'));
    }
  }

  @override
  Future<Either<Failure, void>> signOutFirebase() async {
    try {
      await firebaseAuth.signOut();
      return const Right(null);
    } catch (_) {
      return const Left(AuthFailure('Sign out failed'));
    }
  }
}

class AuthRepositoryImpl extends AuthRepository with _AuthFirebaseMixin {
  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
    required this.firebaseAuth,
  });

  final AuthRemoteDataSource remote;
  @override
  final AuthLocalDataSource local;
  final NetworkInfo networkInfo;
  @override
  final FirebaseAuthService firebaseAuth;

  @override
  Future<Either<Failure, User>> login({
    required String phone,
    required String password,
  }) {
    return _guard(() => remote.login(phone: phone, password: password));
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String phone,
    required String password,
  }) {
    return _guard(
      () => remote.register(name: name, phone: phone, password: password),
    );
  }

  @override
  Future<Either<Failure, User>> getCachedUser() async {
    try {
      return Right(await local.getCachedUser());
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, User>> saveUser(User user) async {
    try {
      final model = UserModel.fromEntity(user);
      await local.cacheUser(model);
      return Right(model);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await firebaseAuth.signOut();
      await local.clear();
      return const Right(null);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (_) {
      try {
        await local.clear();
        return const Right(null);
      } on CacheException catch (error) {
        return Left(CacheFailure(error.message));
      }
    }
  }

  Future<Either<Failure, User>> _guard(Future<UserModel> Function() action) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }
      final user = await action();
      await local.cacheUser(user);
      return Right(user);
    } on AuthException catch (error) {
      return Left(AuthFailure(error.message));
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
