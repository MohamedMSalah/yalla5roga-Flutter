import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_read_result.dart';

abstract class GroupsRepository {
  Future<Either<Failure, GroupReadResult>> markRead(String groupId);
}
