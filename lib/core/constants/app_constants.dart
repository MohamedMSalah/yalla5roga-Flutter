class AppConstants {
  const AppConstants._();

  static const String appName = 'Yalla 5roga';
  static const String downloadUrl = 'https://yalla5roga.com';
  static const String tokenKey = 'auth_token';
  static const String demoToken = 'demo-token';
  static const String userCacheKey = 'cached_user';
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String savedOutingsKey = 'saved_outings';
  static const String outingDraftsKey = 'outing_drafts';
  static const String locationPromptShownKey = 'location_prompt_shown';

  /// `--dart-define=USE_MOCK_API=false` to inject live Dio/`http` repositories.
  /// Defaults to `true` so the app is testable without the backend.
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: true,
  );

  static const Duration mockApiDelay = Duration(milliseconds: 400);
  static const String nominatimUserAgent = 'Yalla5roga/1.0';

  static const Duration splashDuration = Duration(seconds: 2);
  static const int minPasswordLength = 8;
}
