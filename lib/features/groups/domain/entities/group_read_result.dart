class GroupReadResult {
  const GroupReadResult({
    required this.groupId,
    required this.unreadCount,
    required this.unreadGroupCount,
  });

  final String groupId;
  final int unreadCount;
  final int unreadGroupCount;
}
