import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/network_info.dart';
import 'package:yalla_5roga/core/network/remote_guard.dart';
import 'package:yalla_5roga/features/unread/data/datasources/unread_counts_remote_datasource.dart';
import 'package:yalla_5roga/features/unread/domain/entities/unread_counts.dart';
import 'package:yalla_5roga/features/unread/domain/repositories/unread_counts_repository.dart';

class UnreadCountsRepositoryImpl implements UnreadCountsRepository {
  const UnreadCountsRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final UnreadCountsRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, UnreadCounts>> fetchCounts() {
    return guardRemote(networkInfo, remote.getCounts);
  }
}
