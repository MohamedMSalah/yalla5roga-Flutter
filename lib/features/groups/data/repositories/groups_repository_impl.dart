import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/network_info.dart';
import 'package:yalla_5roga/core/network/remote_guard.dart';
import 'package:yalla_5roga/features/groups/data/datasources/groups_remote_datasource.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_read_result.dart';
import 'package:yalla_5roga/features/groups/domain/repositories/groups_repository.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  const GroupsRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final GroupsRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, GroupReadResult>> markRead(String groupId) {
    return guardRemote(networkInfo, () => remote.markRead(groupId));
  }
}
