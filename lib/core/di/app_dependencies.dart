import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalla_5roga/core/constants/api_constants.dart';
import 'package:yalla_5roga/core/di/repository_factory.dart';
import 'package:yalla_5roga/core/localization/locale_provider.dart';
import 'package:yalla_5roga/core/network/api_client.dart';
import 'package:yalla_5roga/core/network/dio_interceptors.dart';
import 'package:yalla_5roga/core/network/network_info.dart';
import 'package:yalla_5roga/core/theme/theme_provider.dart';
import 'package:yalla_5roga/features/auth/data/datasources/firebase_auth_service.dart';
import 'package:yalla_5roga/features/auth/presentation/providers/auth_provider.dart';
import 'package:yalla_5roga/features/discover/presentation/providers/discover_provider.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/geocoding_repository.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outing_chat_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/saved_outings_provider.dart';
import 'package:yalla_5roga/features/setting/presentation/providers/settings_provider.dart';
import 'package:yalla_5roga/features/shell/presentation/providers/shell_provider.dart';

class AppDependencies {
  const AppDependencies({
    required this.theme,
    required this.locale,
    required this.auth,
    required this.notifications,
    required this.outingChat,
    required this.outings,
    required this.savedOutings,
    required this.shell,
    required this.groups,
    required this.discover,
    required this.settings,
    required this.geocoding,
  });

  final ThemeProvider theme;
  final LocaleProvider locale;
  final AuthProvider auth;
  final NotificationsProvider notifications;
  final OutingChatProvider outingChat;
  final OutingsProvider outings;
  final SavedOutingsProvider savedOutings;
  final ShellProvider shell;
  final GroupsProvider groups;
  final DiscoverProvider discover;
  final SettingsProvider settings;
  final GeocodingRepository geocoding;

  static Future<AppDependencies> create() async {
    final prefs = await SharedPreferences.getInstance();
    final networkInfo = NetworkInfoImpl(Connectivity());

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.addAll([
      AuthInterceptor(prefs),
      AppLogInterceptor(),
      ErrorInterceptor(),
    ]);

    final repos = RepositoryFactory(
      apiClient: ApiClient(dio),
      networkInfo: networkInfo,
      prefs: prefs,
    );

    final authRepository = repos.auth();
    final unreadCountsRepository = repos.unreadCounts();
    final auth = AuthProvider(
      repository: authRepository,
      firebaseAuth: FirebaseAuthService(),
    );
    await auth.restoreSession();

    return AppDependencies(
      theme: ThemeProvider(prefs),
      locale: LocaleProvider(prefs),
      auth: auth,
      notifications: NotificationsProvider(
        repository: repos.notifications(),
        unreadCounts: unreadCountsRepository,
      ),
      outingChat: OutingChatProvider(
        repository: repos.outingChat(),
        unreadCounts: unreadCountsRepository,
      ),
      outings: OutingsProvider(),
      savedOutings: SavedOutingsProvider(prefs),
      shell: ShellProvider(),
      groups: GroupsProvider(
        repository: repos.groups(),
        unreadCounts: unreadCountsRepository,
      ),
      discover: DiscoverProvider(),
      settings: SettingsProvider(),
      geocoding: repos.geocoding(),
    );
  }
}
