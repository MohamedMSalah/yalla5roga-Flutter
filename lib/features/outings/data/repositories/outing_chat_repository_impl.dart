import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/network_info.dart';
import 'package:yalla_5roga/core/network/remote_guard.dart';
import 'package:yalla_5roga/features/outings/data/datasources/outing_chat_remote_datasource.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing_chat_read_result.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/outing_chat_repository.dart';

class OutingChatRepositoryImpl implements OutingChatRepository {
  const OutingChatRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final OutingChatRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, OutingChatReadResult>> markRead(String outingId) {
    return guardRemote(networkInfo, () => remote.markRead(outingId));
  }
}
