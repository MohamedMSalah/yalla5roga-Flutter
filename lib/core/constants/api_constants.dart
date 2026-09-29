class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.yalla5roga.com',
  );

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String unreadCounts = '/me/unread-counts';
  static const String notifications = '/notifications';
  static const String notificationsRead = '/notifications/read';

  static String notificationRead(String id) => '/notifications/$id/read';

  static String outingChatRead(String outingId) => '/outings/$outingId/chat/read';

  static String groupRead(String groupId) => '/groups/$groupId/read';
}
