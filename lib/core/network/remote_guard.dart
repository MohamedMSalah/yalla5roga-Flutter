import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/exceptions.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/network_info.dart';

Future<Either<Failure, T>> guardRemote<T>(
  NetworkInfo networkInfo,
  Future<T> Function() action,
) async {
  try {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    return Right(await action());
  } on AuthException catch (error) {
    return Left(AuthFailure(error.message));
  } on NetworkException catch (error) {
    return Left(NetworkFailure(error.message));
  } on AppException catch (error) {
    return Left(ServerFailure(error.message));
  }
}
