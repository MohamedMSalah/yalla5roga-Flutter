import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/features/notifications/domain/entities/notification_item.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, NotificationsFeed>> getNotifications();

  Future<Either<Failure, int>> markAllRead();

  Future<Either<Failure, int>> markRead(String id);

  /// Local / demo push used while the backend notification writer is unavailable.
  Future<Either<Failure, NotificationItem>> pushLocal({
    required String body,
    String? outingId,
    String? groupId,
    bool action = false,
    String? image,
  });
}
