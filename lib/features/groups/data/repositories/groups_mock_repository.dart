import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/mock_repository.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_read_result.dart';
import 'package:yalla_5roga/features/groups/domain/repositories/groups_repository.dart';

class GroupsMockRepository implements GroupsRepository {
  const GroupsMockRepository();

  @override
  Future<Either<Failure, GroupReadResult>> markRead(String groupId) {
    return mockRight(
      GroupReadResult(groupId: groupId, unreadCount: 0, unreadGroupCount: 0),
    );
  }
}
