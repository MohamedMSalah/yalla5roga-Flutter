import 'package:yalla_5roga/core/network/api_payload.dart';
import 'package:yalla_5roga/features/unread/domain/entities/unread_counts.dart';

class UnreadCountsModel extends UnreadCounts {
  const UnreadCountsModel({
    required super.unreadNotificationCount,
    required super.unreadChatCount,
    required super.unreadGroupCount,
    super.chatUnreadByOutingId,
    super.groupUnreadByGroupId,
  });

  factory UnreadCountsModel.fromJson(Map<String, dynamic> json) {
    return UnreadCountsModel(
      unreadNotificationCount: apiInt(json['unreadNotificationCount']),
      unreadChatCount: apiInt(json['unreadChatCount']),
      unreadGroupCount: apiInt(json['unreadGroupCount']),
      chatUnreadByOutingId: _mapCounts(json['chats'], 'outingId'),
      groupUnreadByGroupId: _mapCounts(json['groups'], 'groupId'),
    );
  }

  static Map<String, int> _mapCounts(dynamic raw, String idKey) {
    if (raw is! List) return const {};
    final counts = <String, int>{};
    for (final item in raw) {
      if (item is! Map) continue;
      final id = apiString(item[idKey]);
      if (id == null) continue;
      counts[id] = apiInt(item['unreadCount']);
    }
    return counts;
  }
}
