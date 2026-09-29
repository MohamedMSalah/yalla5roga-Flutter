import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/constants/app_constants.dart';
import 'package:yalla_5roga/core/error/failures.dart';

Future<void> mockDelay() => Future<void>.delayed(AppConstants.mockApiDelay);

Future<Either<Failure, T>> mockRight<T>(T value) async {
  await mockDelay();
  return Right(value);
}
