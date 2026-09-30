import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/network_info.dart';
import 'package:yalla_5roga/core/network/remote_guard.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_member.dart';
import 'package:yalla_5roga/features/outings/data/datasources/outings_remote_datasource.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing_enums.dart';
import 'package:yalla_5roga/features/outings/domain/entities/place.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/outings_repository.dart';

class OutingsRepositoryImpl implements OutingsRepository {
  const OutingsRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final OutingsRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  List<Place> get catalogPlaces => remote.catalogPlaces;

  @override
  String specialEventImage(OutingOccasion occasion) => remote.specialEventImage(occasion);

  @override
  List<GroupMember> membersForOuting(Outing outing) => remote.membersForOuting(outing);

  @override
  Future<Either<Failure, OutingSnapshot>> load() {
    return guardRemote(networkInfo, remote.load);
  }

  @override
  Future<Either<Failure, OutingSnapshot>> add(Outing outing, {String? creatorId}) {
    return guardRemote(networkInfo, () => remote.add(outing, creatorId: creatorId));
  }

  @override
  Future<Either<Failure, OutingSnapshot>> suggestPlaces({
    required String groupId,
    required String title,
    required List<Place> places,
    required int deadlineHours,
    required String createdBy,
    String? createdById,
    String? image,
    DateTime? scheduledAt,
  }) {
    return guardRemote(
      networkInfo,
      () => remote.suggestPlaces(
        groupId: groupId,
        title: title,
        places: places,
        deadlineHours: deadlineHours,
        createdBy: createdBy,
        createdById: createdById,
        image: image,
        scheduledAt: scheduledAt,
      ),
    );
  }

  @override
  Future<Either<Failure, OutingSnapshot>> selectVote(String outingId, int optionIndex) {
    return guardRemote(networkInfo, () => remote.selectVote(outingId, optionIndex));
  }

  @override
  Future<Either<Failure, OutingSnapshot>> setAttendance({
    required String outingId,
    required String memberId,
    required AttendanceStatus status,
  }) {
    return guardRemote(
      networkInfo,
      () => remote.setAttendance(
        outingId: outingId,
        memberId: memberId,
        status: status,
      ),
    );
  }

  @override
  Future<Either<Failure, OutingSnapshot>> refreshLifecycle() {
    return guardRemote(networkInfo, remote.refreshLifecycle);
  }
}
