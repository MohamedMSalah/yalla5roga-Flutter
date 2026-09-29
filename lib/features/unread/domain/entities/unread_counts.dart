class UnreadCounts {
  const UnreadCounts({
    required this.unreadNotificationCount,
    required this.unreadChatCount,
    required this.unreadGroupCount,
    this.chatUnreadByOutingId = const {},
    this.groupUnreadByGroupId = const {},
  });

  final int unreadNotificationCount;
  final int unreadChatCount;
  final int unreadGroupCount;
  final Map<String, int> chatUnreadByOutingId;
  final Map<String, int> groupUnreadByGroupId;
}
