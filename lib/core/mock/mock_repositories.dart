import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/mock/mock_data.dart';
import 'package:yalla_5roga/features/auth/domain/entities/phone_verification.dart';
import 'package:yalla_5roga/features/auth/domain/entities/user.dart';
import 'package:yalla_5roga/features/auth/domain/repositories/auth_repository.dart';
import 'package:yalla_5roga/features/discover/domain/entities/suggested_place.dart';
import 'package:yalla_5roga/features/discover/domain/repositories/discover_repository.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_member.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_read_result.dart';
import 'package:yalla_5roga/features/groups/domain/repositories/groups_repository.dart';
import 'package:yalla_5roga/features/notifications/domain/entities/notification_item.dart';
import 'package:yalla_5roga/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:yalla_5roga/features/outings/domain/entities/chat_message.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing_chat_read_result.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing_enums.dart';
import 'package:yalla_5roga/features/outings/domain/entities/place.dart';
import 'package:yalla_5roga/features/outings/domain/entities/saved_outing.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/geocoding_repository.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/outing_chat_repository.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/outings_repository.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/saved_outings_repository.dart';
import 'package:yalla_5roga/features/unread/domain/entities/unread_counts.dart';
import 'package:yalla_5roga/features/unread/domain/repositories/unread_counts_repository.dart';

// Temporary mock repositories for AppConfig.useMockData.
// Delete this file with lib/core/mock/ when demos are done.

class MockAuthRepository implements AuthRepository {
  @override
  bool get hasFirebaseSession => MockData.sessionActive;

  @override
  bool get hasPasswordProvider => true;

  @override
  Future<Either<Failure, User>> getCachedUser() async {
    if (!MockData.sessionActive) {
      return const Left(CacheFailure('No mock session'));
    }
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, User>> saveUser(User user) async {
    MockData.currentUser = user;
    MockData.sessionActive = true;
    return Right(user);
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    MockData.sessionActive = true;
    MockData.updateCurrentUser(email: email);
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String verificationId,
    required String smsCode,
  }) async {
    MockData.sessionActive = true;
    MockData.currentUser = User(
      id: MockData.currentUser.id,
      name: name,
      phone: phone,
      email: email,
      token: 'mock-demo-token',
      imageUrl: MockData.currentUser.imageUrl,
    );
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    MockData.sessionActive = true;
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    MockData.sessionActive = true;
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, User>> updateProfileData({
    String? name,
    String? imageUrl,
  }) async {
    MockData.updateCurrentUser(name: name, imageUrl: imageUrl);
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, void>> confirmPassword({
    required String password,
  }) async {
    if (password.trim().isEmpty) {
      return const Left(AuthFailure('Incorrect password', 'wrong-password'));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> syncProfileToBackend({
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
  }) async {
    MockData.updateCurrentUser(
      name: name,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
    );
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, void>> requestEmailChange({
    required String newEmail,
    required String currentPassword,
  }) async {
    MockData.updateCurrentUser(email: newEmail);
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, User>> updatePhoneNumber({
    required String verificationId,
    required String smsCode,
    required String phone,
  }) async {
    MockData.updateCurrentUser(phone: phone);
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    MockData.sessionActive = false;
    return const Right(null);
  }

  @override
  Future<Either<Failure, PhoneVerification>> sendOtp({
    required String phone,
    int? forceResendingToken,
  }) async {
    return const Right(
      PhoneVerification(verificationId: 'mock-verification-id', resendToken: 1),
    );
  }

  @override
  Future<Either<Failure, User>> verifyOtpAndCache({
    required String verificationId,
    required String smsCode,
    required String phone,
    String? name,
  }) async {
    MockData.sessionActive = true;
    MockData.updateCurrentUser(phone: phone, name: name);
    return Right(MockData.currentUser);
  }

  @override
  Future<Either<Failure, String?>> idToken({bool forceRefresh = false}) async {
    return Right(MockData.currentUser.token);
  }

  @override
  Future<Either<Failure, void>> signOutFirebase() async {
    MockData.sessionActive = false;
    return const Right(null);
  }
}

class MockGroupsRepository implements GroupsRepository {
  @override
  Future<Either<Failure, List<Group>>> getGroups() async {
    return Right(List<Group>.from(MockData.groups));
  }

  @override
  Future<Either<Failure, Group>> getGroup(String groupId) async {
    final group = MockData.groups.cast<Group?>().firstWhere(
      (g) => g?.id == groupId,
      orElse: () => null,
    );
    if (group == null) {
      return const Left(ServerFailure('Group not found'));
    }
    return Right(group);
  }

  @override
  Future<Either<Failure, Group>> createGroup(Group group) async {
    final id = group.id.isEmpty
        ? 'g_${DateTime.now().millisecondsSinceEpoch}'
        : group.id;
    final created = group.copyWith(
      image: group.image.isEmpty ? MockData.defaultCoverImage : group.image,
    );
    // Group has no id in copyWith — rebuild with id if needed.
    final withId = Group(
      id: id,
      name: created.name,
      members: created.members,
      outings: created.outings,
      preview: created.preview,
      bio: created.bio,
      avatars: created.avatars,
      image: created.image,
      people: created.people,
      lastMessage: created.lastMessage,
      unread: created.unread,
      featured: created.featured,
      decision: created.decision,
      myRole: created.myRole,
    );
    return Right(MockData.upsertGroup(withId));
  }

  @override
  Future<Either<Failure, Group>> updateGroup(Group group) async {
    return Right(MockData.upsertGroup(group));
  }

  @override
  Future<Either<Failure, Group>> addMember(
    String groupId,
    GroupMember member,
  ) async {
    final updated = MockData.addMember(groupId, member);
    if (updated == null) {
      return const Left(ServerFailure('Group not found'));
    }
    return Right(updated);
  }

  @override
  Future<Either<Failure, Group>> removeMember(
    String groupId,
    String memberId,
  ) async {
    final updated = MockData.removeMember(groupId, memberId);
    if (updated == null) {
      return const Left(ServerFailure('Group not found'));
    }
    return Right(updated);
  }

  @override
  Future<Either<Failure, void>> leaveGroup(String groupId) async {
    final ok = MockData.leaveGroup(groupId);
    if (!ok) {
      return const Left(ServerFailure('Group not found'));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, GroupReadResult>> markRead(String groupId) async {
    return Right(MockData.markGroupRead(groupId));
  }

  @override
  GroupMember? memberById(String id) => MockData.memberById(id);

  @override
  GroupMember? memberByPhone(String phone) => MockData.memberByPhone(phone);

  @override
  String groupsForMember(String id) => MockData.groupsForMember(id);

  @override
  List<GroupMember> get contacts => MockData.contacts;
}

class MockOutingsRepository implements OutingsRepository {
  @override
  List<Place> get catalogPlaces => MockData.catalogPlaces;

  @override
  List<GroupMember> membersForOuting(Outing outing) =>
      MockData.membersForOuting(outing);

  @override
  String specialEventImage(OutingOccasion occasion) =>
      MockData.specialEventImage(occasion);

  @override
  Future<Either<Failure, OutingSnapshot>> load() async {
    return Right(MockData.outingSnapshot());
  }

  @override
  Future<Either<Failure, OutingSnapshot>> add(
    Outing outing, {
    String? creatorId,
  }) async {
    return Right(MockData.addOuting(outing, creatorId: creatorId));
  }

  @override
  Future<Either<Failure, OutingSnapshot>> suggestPlaces({
    required String groupId,
    required String title,
    required List<Place> places,
    required int deadlineHours,
    required String createdBy,
    String? createdById,
    String? image,
    DateTime? scheduledAt,
  }) async {
    return Right(
      MockData.suggestPlaces(
        groupId: groupId,
        title: title,
        places: places,
        deadlineHours: deadlineHours,
        createdBy: createdBy,
        createdById: createdById,
        image: image,
        scheduledAt: scheduledAt,
      ),
    );
  }

  @override
  Future<Either<Failure, OutingSnapshot>> selectVote(
    String outingId,
    int optionIndex,
  ) async {
    return Right(MockData.selectVote(outingId, optionIndex));
  }

  @override
  Future<Either<Failure, OutingSnapshot>> setAttendance({
    required String outingId,
    required String memberId,
    required AttendanceStatus status,
  }) async {
    return Right(
      MockData.setAttendance(
        outingId: outingId,
        memberId: memberId,
        status: status,
      ),
    );
  }

  @override
  Future<Either<Failure, OutingSnapshot>> refreshLifecycle() async {
    return Right(MockData.refreshLifecycle());
  }
}

class MockOutingChatRepository implements OutingChatRepository {
  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String outingId,
  ) async {
    final messages = MockData.messagesByOuting[outingId] ?? const [];
    return Right(List<ChatMessage>.from(messages));
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String outingId,
    required String text,
    required String senderId,
    required String senderName,
  }) async {
    return Right(
      MockData.sendMessage(
        outingId: outingId,
        text: text,
        senderId: senderId,
        senderName: senderName,
      ),
    );
  }

  @override
  Future<Either<Failure, OutingChatReadResult>> markRead(
    String outingId,
  ) async {
    return Right(MockData.markChatRead(outingId));
  }
}

class MockDiscoverRepository implements DiscoverRepository {
  @override
  Future<Either<Failure, List<SuggestedPlace>>> getPlaces({
    OutingVibe? vibe,
  }) async {
    final all = MockData.suggestedPlaces;
    if (vibe == null) return Right(List<SuggestedPlace>.from(all));
    return Right(all.where((p) => p.vibe == vibe).toList());
  }

  @override
  Future<Either<Failure, List<SuggestedPlace>>> getFeaturedPlaces() async {
    return Right(MockData.suggestedPlaces.where((p) => p.featured).toList());
  }

  @override
  Future<Either<Failure, SuggestedPlace>> getPlace(String placeId) async {
    final place = MockData.suggestedPlaces.cast<SuggestedPlace?>().firstWhere(
      (p) => p?.id == placeId,
      orElse: () => null,
    );
    if (place == null) {
      return const Left(ServerFailure('Place not found'));
    }
    return Right(place);
  }

  @override
  List<Place> catalogPlaces() => MockData.catalogPlaces;
}

class MockNotificationsRepository implements NotificationsRepository {
  @override
  Future<Either<Failure, NotificationsFeed>> getNotifications() async {
    return Right(MockData.notificationsFeed());
  }

  @override
  Future<Either<Failure, int>> markAllRead() async {
    return Right(MockData.markAllNotificationsRead());
  }

  @override
  Future<Either<Failure, int>> markRead(String id) async {
    return Right(MockData.markNotificationRead(id));
  }
}

class MockUnreadCountsRepository implements UnreadCountsRepository {
  @override
  Future<Either<Failure, UnreadCounts>> fetchCounts() async {
    return Right(MockData.unreadCounts());
  }
}

class MockSavedOutingsRepository implements SavedOutingsRepository {
  @override
  Future<Either<Failure, List<SavedOuting>>> getSaved() async {
    return Right(List<SavedOuting>.from(MockData.savedOutings));
  }

  @override
  Future<Either<Failure, List<OutingDraft>>> getDrafts() async {
    return Right(List<OutingDraft>.from(MockData.drafts));
  }

  @override
  Future<Either<Failure, List<SavedOuting>>> saveOuting(
    SavedOuting outing,
  ) async {
    MockData.savedOutings = [
      outing,
      ...MockData.savedOutings.where((item) => item.id != outing.id),
    ];
    return Right(List<SavedOuting>.from(MockData.savedOutings));
  }

  @override
  Future<Either<Failure, List<SavedOuting>>> removeSaved(String id) async {
    MockData.savedOutings = MockData.savedOutings
        .where((item) => item.id != id)
        .toList();
    return Right(List<SavedOuting>.from(MockData.savedOutings));
  }

  @override
  Future<Either<Failure, List<OutingDraft>>> saveDraft(
    OutingDraft draft,
  ) async {
    MockData.drafts = [
      draft,
      ...MockData.drafts.where((item) => item.id != draft.id),
    ];
    return Right(List<OutingDraft>.from(MockData.drafts));
  }

  @override
  Future<Either<Failure, List<OutingDraft>>> removeDraft(String id) async {
    MockData.drafts = MockData.drafts.where((item) => item.id != id).toList();
    return Right(List<OutingDraft>.from(MockData.drafts));
  }

  @override
  Future<Either<Failure, bool>> isSaved(String id) async {
    return Right(MockData.savedOutings.any((item) => item.id == id));
  }
}

class MockGeocodingRepository implements GeocodingRepository {
  @override
  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    GeocodingHit? best;
    var bestDistance = double.infinity;
    for (final hit in MockData.geocodingHits) {
      final dLat = hit.latitude - latitude;
      final dLng = hit.longitude - longitude;
      final distance = dLat * dLat + dLng * dLng;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = hit;
      }
    }
    return best?.name ?? 'Demo City';
  }

  @override
  Future<List<GeocodingHit>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return MockData.geocodingHits
        .where((hit) => hit.name.toLowerCase().contains(q))
        .toList();
  }
}
