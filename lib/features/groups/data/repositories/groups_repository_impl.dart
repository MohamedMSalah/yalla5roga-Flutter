import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/network_info.dart';
import 'package:yalla_5roga/core/network/remote_guard.dart';
import 'package:yalla_5roga/features/groups/data/datasources/groups_remote_datasource.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_member.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_read_result.dart';
import 'package:yalla_5roga/features/groups/domain/repositories/groups_repository.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  const GroupsRepositoryImpl({required this.remote, required this.networkInfo});

  final GroupsRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  List<GroupMember> get contacts => remote.contacts;

  @override
  Future<Either<Failure, List<Group>>> getGroups() {
    return guardRemote(networkInfo, remote.getGroups);
  }

  @override
  Future<Either<Failure, Group>> getGroup(String groupId) {
    return guardRemote(networkInfo, () => remote.getGroup(groupId));
  }

  @override
  Future<Either<Failure, Group>> createGroup(Group group) {
    return guardRemote(networkInfo, () => remote.createGroup(group));
  }

  @override
  Future<Either<Failure, Group>> updateGroup(Group group) {
    return guardRemote(networkInfo, () => remote.updateGroup(group));
  }

  @override
  Future<Either<Failure, Group>> addMember(String groupId, GroupMember member) {
    return guardRemote(networkInfo, () => remote.addMember(groupId, member));
  }

  @override
  Future<Either<Failure, Group>> removeMember(String groupId, String memberId) {
    return guardRemote(
      networkInfo,
      () => remote.removeMember(groupId, memberId),
    );
  }

  @override
  Future<Either<Failure, void>> leaveGroup(String groupId) {
    return guardRemote(networkInfo, () => remote.leaveGroup(groupId));
  }

  @override
  Future<Either<Failure, GroupReadResult>> markRead(String groupId) {
    return guardRemote(networkInfo, () => remote.markRead(groupId));
  }

  @override
  GroupMember? memberById(String id) => remote.memberById(id);

  @override
  GroupMember? memberByPhone(String phone) => remote.memberByPhone(phone);

  @override
  String groupsForMember(String id) => remote.groupsForMember(id);
}
