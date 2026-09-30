import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/network_info.dart';
import 'package:yalla_5roga/core/network/remote_guard.dart';
import 'package:yalla_5roga/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:yalla_5roga/features/notifications/domain/entities/notification_item.dart';
import 'package:yalla_5roga/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final NotificationsRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, NotificationsFeed>> getNotifications() {
    return guardRemote(networkInfo, remote.getNotifications);
  }

  @override
  Future<Either<Failure, int>> markAllRead() {
    return guardRemote(networkInfo, remote.markAllRead);
  }

  @override
  Future<Either<Failure, int>> markRead(String id) {
    return guardRemote(networkInfo, () => remote.markRead(id));
  }
}
