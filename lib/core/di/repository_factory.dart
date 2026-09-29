import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalla_5roga/core/constants/app_constants.dart';
import 'package:yalla_5roga/core/network/api_client.dart';
import 'package:yalla_5roga/core/network/network_info.dart';
import 'package:yalla_5roga/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:yalla_5roga/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yalla_5roga/features/auth/data/repositories/auth_mock_repository.dart';
import 'package:yalla_5roga/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yalla_5roga/features/auth/domain/repositories/auth_repository.dart';
import 'package:yalla_5roga/features/groups/data/datasources/groups_remote_datasource.dart';
import 'package:yalla_5roga/features/groups/data/repositories/groups_mock_repository.dart';
import 'package:yalla_5roga/features/groups/data/repositories/groups_repository_impl.dart';
import 'package:yalla_5roga/features/groups/domain/repositories/groups_repository.dart';
import 'package:yalla_5roga/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:yalla_5roga/features/notifications/data/repositories/notifications_mock_repository.dart';
import 'package:yalla_5roga/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:yalla_5roga/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:yalla_5roga/features/outings/data/datasources/outing_chat_remote_datasource.dart';
import 'package:yalla_5roga/features/outings/data/repositories/geocoding_http_repository.dart';
import 'package:yalla_5roga/features/outings/data/repositories/geocoding_mock_repository.dart';
import 'package:yalla_5roga/features/outings/data/repositories/outing_chat_mock_repository.dart';
import 'package:yalla_5roga/features/outings/data/repositories/outing_chat_repository_impl.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/geocoding_repository.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/outing_chat_repository.dart';
import 'package:yalla_5roga/features/unread/data/datasources/unread_counts_remote_datasource.dart';
import 'package:yalla_5roga/features/unread/data/repositories/unread_counts_mock_repository.dart';
import 'package:yalla_5roga/features/unread/data/repositories/unread_counts_repository_impl.dart';
import 'package:yalla_5roga/features/unread/domain/repositories/unread_counts_repository.dart';

/// Picks mock (delay + DemoData) or live repositories from [AppConstants.useMockApi].
///
/// Live **app** API repos use Dio/`ApiClient`. Nominatim geocoding uses `package:http`.
class RepositoryFactory {
  const RepositoryFactory({
    required this.apiClient,
    required this.networkInfo,
    required this.prefs,
    this.useMock = AppConstants.useMockApi,
  });

  final ApiClient apiClient;
  final NetworkInfo networkInfo;
  final SharedPreferences prefs;
  final bool useMock;

  T _pick<T>({required T Function() live, required T Function() mock}) {
    return useMock ? mock() : live();
  }

  AuthRepository auth() {
    final local = AuthLocalDataSourceImpl(prefs);
    return _pick(
      live: () => AuthRepositoryImpl(
        remote: AuthRemoteDataSourceImpl(apiClient),
        local: local,
        networkInfo: networkInfo,
      ),
      mock: () => AuthMockRepository(local: local),
    );
  }

  NotificationsRepository notifications() {
    return _pick(
      live: () => NotificationsRepositoryImpl(
        remote: NotificationsRemoteDataSourceImpl(apiClient),
        networkInfo: networkInfo,
      ),
      mock: NotificationsMockRepository.new,
    );
  }

  UnreadCountsRepository unreadCounts() {
    return _pick(
      live: () => UnreadCountsRepositoryImpl(
        remote: UnreadCountsRemoteDataSourceImpl(apiClient),
        networkInfo: networkInfo,
      ),
      mock: UnreadCountsMockRepository.new,
    );
  }

  GroupsRepository groups() {
    return _pick(
      live: () => GroupsRepositoryImpl(
        remote: GroupsRemoteDataSourceImpl(apiClient),
        networkInfo: networkInfo,
      ),
      mock: GroupsMockRepository.new,
    );
  }

  OutingChatRepository outingChat() {
    return _pick(
      live: () => OutingChatRepositoryImpl(
        remote: OutingChatRemoteDataSourceImpl(apiClient),
        networkInfo: networkInfo,
      ),
      mock: OutingChatMockRepository.new,
    );
  }

  GeocodingRepository geocoding() {
    return _pick(
      live: () => GeocodingHttpRepository(),
      mock: () => const GeocodingMockRepository(),
    );
  }
}
