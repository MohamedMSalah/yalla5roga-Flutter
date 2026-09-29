import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/demo/demo_data.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/mock_repository.dart';
import 'package:yalla_5roga/features/notifications/domain/entities/notification_item.dart';
import 'package:yalla_5roga/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsMockRepository implements NotificationsRepository {
  NotificationsMockRepository() : _items = _fromDemo();

  var _items = <NotificationItem>[];

  static List<NotificationItem> _fromDemo() {
    return [
      for (final item in DemoData.notifications)
        NotificationItem(
          id: item.id,
          body: item.body,
          time: item.time,
          unread: item.unread,
          image: item.image,
          eventId: item.eventId,
          groupId: item.groupId,
          action: item.action,
        ),
    ];
  }

  int get _unread => _items.where((item) => item.unread).length;

  @override
  Future<Either<Failure, NotificationsFeed>> getNotifications() {
    return mockRight(
      NotificationsFeed(unreadCount: _unread, items: List.unmodifiable(_items)),
    );
  }

  @override
  Future<Either<Failure, int>> markAllRead() async {
    await mockDelay();
    _items = [for (final item in _items) item.copyWith(unread: false)];
    return const Right(0);
  }

  @override
  Future<Either<Failure, int>> markRead(String id) async {
    await mockDelay();
    _items = [
      for (final item in _items)
        if (item.id == id) item.copyWith(unread: false) else item,
    ];
    return Right(_unread);
  }
}
