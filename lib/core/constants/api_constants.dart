class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.yalla5roga.com',
  );

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Me
  static const String unreadCounts = '/me/unread-counts';
  static const String savedOutings = '/me/saved-outings';
  static const String fcmToken = '/me/fcm-token';

  static String savedOuting(String id) => '/me/saved-outings/$id';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsRead = '/notifications/read';

  static String notificationRead(String id) => '/notifications/$id/read';

  // Groups (placeholders until Node.js backend)
  static const String groups = '/groups';

  static String group(String groupId) => '/groups/$groupId';

  static String groupMembers(String groupId) => '/groups/$groupId/members';

  static String groupRead(String groupId) => '/groups/$groupId/read';

  // Outings (placeholders until Node.js backend)
  static const String outings = '/outings';

  static String outing(String outingId) => '/outings/$outingId';

  static String outingVotes(String outingId) => '/outings/$outingId/votes';

  static String outingAttendance(String outingId) => '/outings/$outingId/attendance';

  static String outingChatMessages(String outingId) => '/outings/$outingId/chat/messages';

  static String outingChatRead(String outingId) => '/outings/$outingId/chat/read';

  // Discover / places (placeholders)
  static const String places = '/places';

  static String place(String placeId) => '/places/$placeId';
}
