import 'package:flutter/foundation.dart';
import 'package:yalla_5roga/core/error/app_error_feedback.dart';
import 'package:yalla_5roga/core/localization/l10n.dart';
import 'package:yalla_5roga/core/monitoring/analytics_service.dart';
import 'package:yalla_5roga/core/utils/validators.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_member.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_role.dart';
import 'package:yalla_5roga/features/groups/domain/repositories/groups_repository.dart';
import 'package:yalla_5roga/features/unread/domain/entities/unread_counts.dart';
import 'package:yalla_5roga/features/unread/domain/repositories/unread_counts_repository.dart';

class GroupsProvider extends ChangeNotifier {
  GroupsProvider({required this.repository, required this.unreadCounts});

  final GroupsRepository repository;
  final UnreadCountsRepository unreadCounts;

  var _groups = <Group>[];
  int _unreadGroupCount = 0;
  int _filter = 0;
  var _searching = false;
  var _query = '';
  String? _createImage;
  final _createPhones = <String>[];
  var _isLoading = false;
  var _isUpdating = false;
  var _hasLoaded = false;
  String? _errorMessage;
  var _epoch = 0;

  List<Group> get groups => List.unmodifiable(_groups);

  int get unreadGroupCount => _unreadGroupCount;

  bool get isLoading => _isLoading;

  bool get isUpdating => _isUpdating;

  bool get hasLoaded => _hasLoaded;

  bool get isInitialLoading => !_hasLoaded;

  String? get errorMessage => _errorMessage;

  int get filter => _filter;

  bool get searching => _searching;

  String get query => _query;

  String? get createImage => _createImage;

  List<String> get createPhones => List.unmodifiable(_createPhones);

  List<GroupMember> get contacts => repository.contacts;

  String groupsForMember(String id) => repository.groupsForMember(id);

  GroupMember? memberById(String id) => repository.memberById(id);

  GroupMember? memberByPhone(String phone) => repository.memberByPhone(phone);

  List<Group> get visible {
    final needle = _query.trim().toLowerCase();
    return [
      for (final group in _groups)
        if ((_filter != 1 || group.featured || group.unread > 0) &&
            (needle.isEmpty || group.name.toLowerCase().contains(needle)))
          group,
    ];
  }

  Group? findById(String id) {
    for (final group in _groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  Group byId(String id) =>
      findById(id) ?? (_groups.isNotEmpty ? _groups.first : _emptyGroup(id));

  static Group _emptyGroup(String id) {
    return Group(
      id: id,
      name: '',
      members: 0,
      outings: 0,
      preview: '',
      avatars: const [],
      image: '',
      people: const [],
    );
  }

  Future<void> loadGroups() async {
    final result = await repository.getGroups();
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppErrorFeedback.report(
          failure,
          kind: AppErrorKind.load,
          context: 'loadGroups',
        );
      },
      (groups) {
        _groups = List.of(groups);
        _unreadGroupCount = _groups.fold(0, (sum, group) => sum + group.unread);
        _errorMessage = null;
      },
    );
    _hasLoaded = true;
    notifyListeners();
  }

  void setFilter(int value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  void openSearch() {
    if (_searching) return;
    _searching = true;
    notifyListeners();
  }

  void closeSearch() {
    if (!_searching && _query.isEmpty) return;
    _searching = false;
    _query = '';
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void setCreateImage(String path) {
    _createImage = path;
    notifyListeners();
  }

  String? addCreatePhone(String raw, L10n l10n) {
    final error = Validators.phone(raw, l10n);
    if (error != null) return error;
    final phone = Validators.normalizePhone(raw);
    if (_createPhones.contains(phone)) return l10n.phoneAlreadyAdded;
    _createPhones.add(phone);
    notifyListeners();
    return null;
  }

  void removeCreatePhone(String phone) {
    _createPhones.remove(phone);
    notifyListeners();
  }

  void resetCreate({bool notify = true}) {
    _createImage = null;
    _createPhones.clear();
    if (notify) notifyListeners();
  }

  String roleLabel(GroupRole role, L10n l10n) {
    return switch (role) {
      GroupRole.owner => l10n.owner,
      GroupRole.admin => l10n.admin,
      GroupRole.member => l10n.member,
    };
  }

  Future<Group?> createGroup(
    String name, {
    required String ownerName,
    String? ownerAvatar,
  }) async {
    if (name.trim().isEmpty) return null;
    if (_createImage == null) return null;
    final people = [
      GroupMember(
        id: 'me',
        name: ownerName,
        avatar: ownerAvatar ?? '',
        role: GroupRole.owner,
      ),
      for (final phone in _createPhones) _memberFromPhone(phone),
    ];
    final group = Group(
      id: 'new-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      members: people.length,
      outings: 0,
      preview: '',
      avatars: people.map((person) => person.avatar).toList(),
      image: _createImage!,
      people: people,
      myRole: GroupRole.owner,
    );
    final result = await repository.createGroup(group);
    Group? created;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppErrorFeedback.report(
          failure,
          kind: AppErrorKind.send,
          context: 'createGroup',
        );
      },
      (value) {
        created = value;
        _groups = [value, ..._groups.where((item) => item.id != value.id)];
        AnalyticsService.instance.createGroup();
      },
    );
    resetCreate(notify: false);
    notifyListeners();
    return created;
  }

  Future<void> updateImage(String groupId, String url) async {
    final current = byId(groupId);
    final result = await repository.updateGroup(current.copyWith(image: url));
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppErrorFeedback.report(
          failure,
          kind: AppErrorKind.send,
          context: 'updateGroupImage',
        );
      },
      (group) {
        _groups = [
          for (final item in _groups)
            if (item.id == group.id) group else item,
        ];
      },
    );
    notifyListeners();
  }

  Future<String?> addMember(String groupId, String phone, L10n l10n) async {
    final group = byId(groupId);
    if (group.people.any((person) {
      final personPhone = person.phone;
      return person.id == phone ||
          person.name == phone ||
          (personPhone != null && personPhone == phone);
    })) {
      return l10n.phoneAlreadyAdded;
    }
    final member = _memberFromPhone(phone);
    final result = await repository.addMember(groupId, member);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppErrorFeedback.report(
          failure,
          kind: AppErrorKind.send,
          context: 'addMember',
        );
      },
      (updated) {
        _groups = [
          for (final item in _groups)
            if (item.id == updated.id) updated else item,
        ];
        AnalyticsService.instance.joinGroup();
      },
    );
    notifyListeners();
    return null;
  }

  Future<void> removeMember(String groupId, GroupMember person) async {
    if (person.role == GroupRole.owner) return;
    final result = await repository.removeMember(groupId, person.id);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppErrorFeedback.report(
          failure,
          kind: AppErrorKind.send,
          context: 'removeMember',
        );
      },
      (updated) {
        _groups = [
          for (final item in _groups)
            if (item.id == updated.id) updated else item,
        ];
      },
    );
    notifyListeners();
  }

  void applyCounts(UnreadCounts counts) {
    _unreadGroupCount = counts.unreadGroupCount;
    _groups = [
      for (final group in _groups)
        group.copyWith(unread: counts.groupUnreadByGroupId[group.id] ?? 0),
    ];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    final token = ++_epoch;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await loadGroups();
    final result = await unreadCounts.fetchCounts();
    if (token != _epoch) {
      _finishInitialLoad();
      return;
    }
    result.fold<void>((failure) {
      _errorMessage = failure.message;
      AppErrorFeedback.report(
        failure,
        kind: AppErrorKind.load,
        context: 'groupsRefresh',
      );
    }, applyCounts);

    _finishInitialLoad();
  }

  void _finishInitialLoad() {
    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
  }

  Future<bool> markRead(String groupId) async {
    final token = ++_epoch;
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.markRead(groupId);
    if (token != _epoch) return false;
    final success = result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppErrorFeedback.report(
          failure,
          kind: AppErrorKind.send,
          context: 'groupMarkRead',
        );
        return false;
      },
      (read) {
        _unreadGroupCount = read.unreadGroupCount;
        _groups = [
          for (final group in _groups)
            if (group.id == read.groupId)
              group.copyWith(unread: read.unreadCount)
            else
              group,
        ];
        return true;
      },
    );

    _isUpdating = false;
    notifyListeners();
    return success;
  }

  void clear() {
    _epoch++;
    _unreadGroupCount = 0;
    _groups = [for (final group in _groups) group.copyWith(unread: 0)];
    _isLoading = false;
    _isUpdating = false;
    _hasLoaded = false;
    _errorMessage = null;
    notifyListeners();
  }

  GroupMember _memberFromPhone(String phone) {
    final known = repository.memberByPhone(phone);
    if (known != null) {
      return GroupMember(
        id: known.id,
        name: known.name,
        avatar: known.avatar,
        phone: known.phone ?? phone,
        role: known.role,
      );
    }
    return GroupMember(id: phone, name: phone, phone: phone, avatar: '');
  }
}
