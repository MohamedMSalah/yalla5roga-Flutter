class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.body,
    required this.time,
    required this.unread,
    this.image,
    this.eventId,
    this.groupId,
    this.action = false,
  });

  final String id;
  final String body;
  final String time;
  final bool unread;
  final String? image;
  final String? eventId;
  final String? groupId;
  final bool action;

  NotificationItem copyWith({bool? unread}) {
    return NotificationItem(
      id: id,
      body: body,
      time: time,
      unread: unread ?? this.unread,
      image: image,
      eventId: eventId,
      groupId: groupId,
      action: action,
    );
  }
}

class NotificationsFeed {
  const NotificationsFeed({
    required this.unreadCount,
    required this.items,
  });

  final int unreadCount;
  final List<NotificationItem> items;
}
