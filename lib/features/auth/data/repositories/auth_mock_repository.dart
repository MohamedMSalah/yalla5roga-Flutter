import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/constants/app_constants.dart';
import 'package:yalla_5roga/core/error/exceptions.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/mock_repository.dart';
import 'package:yalla_5roga/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:yalla_5roga/features/auth/data/models/user_model.dart';
import 'package:yalla_5roga/features/auth/domain/entities/user.dart';
import 'package:yalla_5roga/features/auth/domain/repositories/auth_repository.dart';

class AuthMockRepository implements AuthRepository {
  const AuthMockRepository({required this.local});

  final AuthLocalDataSource local;

  static const _avatar =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80';

  @override
  Future<Either<Failure, User>> login({
    required String phone,
    required String password,
  }) {
    return _cacheDemo(
      UserModel(
        id: 'demo-user',
        name: 'Ahmed Hassan',
        phone: phone,
        email: 'ahmed@example.com',
        token: AppConstants.demoToken,
        imageUrl: _avatar,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String phone,
    required String password,
  }) {
    return _cacheDemo(
      UserModel(
        id: 'demo-user',
        name: name,
        phone: phone,
        token: AppConstants.demoToken,
        imageUrl: _avatar,
      ),
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
      await local.clear();
      return const Right(null);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }

  Future<Either<Failure, User>> _cacheDemo(UserModel user) async {
    await mockDelay();
    try {
      await local.cacheUser(user);
      return Right(user);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }
}
