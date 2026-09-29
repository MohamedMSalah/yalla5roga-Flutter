import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/demo/demo_data.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/mock_repository.dart';
import 'package:yalla_5roga/features/unread/domain/entities/unread_counts.dart';
import 'package:yalla_5roga/features/unread/domain/repositories/unread_counts_repository.dart';

class UnreadCountsMockRepository implements UnreadCountsRepository {
  const UnreadCountsMockRepository();

  static UnreadCounts get demoCounts {
    final groupUnread = <String, int>{
      for (final group in DemoData.groups)
        if (group.unread > 0) group.id: group.unread,
    };
    return UnreadCounts(
      unreadNotificationCount: DemoData.notifications.where((item) => item.unread).length,
      unreadChatCount: 3,
      unreadGroupCount: groupUnread.values.fold(0, (sum, value) => sum + value),
      chatUnreadByOutingId: const {
        'sunset-picnic': 2,
        'weekend-brunch': 1,
      },
      groupUnreadByGroupId: groupUnread,
    );
  }

  @override
  Future<Either<Failure, UnreadCounts>> fetchCounts() => mockRight(demoCounts);
}
