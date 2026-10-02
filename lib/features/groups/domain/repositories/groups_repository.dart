import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_member.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_read_result.dart';

abstract class GroupsRepository {
  Future<Either<Failure, List<Group>>> getGroups();

  Future<Either<Failure, Group>> getGroup(String groupId);

  Future<Either<Failure, Group>> createGroup(Group group);

  Future<Either<Failure, Group>> updateGroup(Group group);

  Future<Either<Failure, Group>> addMember(String groupId, GroupMember member);

  Future<Either<Failure, Group>> removeMember(String groupId, String memberId);

  /// Leaves the group as the current user. Backend owns ownership transfer rules.
  Future<Either<Failure, void>> leaveGroup(String groupId);

  Future<Either<Failure, GroupReadResult>> markRead(String groupId);

  GroupMember? memberById(String id);

  GroupMember? memberByPhone(String phone);

  String groupsForMember(String id);

  List<GroupMember> get contacts;
}
