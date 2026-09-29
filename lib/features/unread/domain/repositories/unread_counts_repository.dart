import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/features/unread/domain/entities/unread_counts.dart';

abstract class UnreadCountsRepository {
  Future<Either<Failure, UnreadCounts>> fetchCounts();
}
