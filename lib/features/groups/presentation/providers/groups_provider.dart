import 'package:flutter/foundation.dart';
import 'package:yalla_5roga/core/demo/demo_data.dart';
import 'package:yalla_5roga/core/localization/l10n.dart';
import 'package:yalla_5roga/core/utils/validators.dart';
import 'package:yalla_5roga/features/groups/domain/repositories/groups_repository.dart';
import 'package:yalla_5roga/features/unread/domain/entities/unread_counts.dart';
import 'package:yalla_5roga/features/unread/domain/repositories/unread_counts_repository.dart';

class GroupsProvider extends ChangeNotifier {
  GroupsProvider({
    required this.repository,
    required this.unreadCounts,
  }) {
    _groups = List.of(DemoData.groups);
    _unreadGroupCount = _groups.fold(0, (sum, group) => sum + group.unread);
  }

  final GroupsRepository repository;
  final UnreadCountsRepository unreadCounts;

  var _groups = <DemoGroup>[];
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

  List<DemoGroup> get groups => List.unmodifiable(_groups);

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

  List<DemoGroup> get visible {
    final needle = _query.trim().toLowerCase();
    return [
      for (final group in _groups)
        if ((_filter != 1 || group.featured || group.unread > 0) &&
            (needle.isEmpty || group.name.toLowerCase().contains(needle)))
          group,
    ];
  }

  DemoGroup? findById(String id) {
    for (final group in _groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  // TODO: GET /groups/{id} when group CRUD exists. Demo stand-in keeps taps testable.
  DemoGroup byId(String id) => findById(id) ?? DemoData.groupById(id);

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

  DemoGroup? createGroup(String name, {required String ownerName, String? ownerAvatar}) {
    if (name.trim().isEmpty) return null;
    if (_createImage == null) return null;
    final people = [
      DemoMember(
        id: 'me',
        name: ownerName,
        avatar: ownerAvatar ?? DemoData.avatars.last,
        role: GroupRole.owner,
      ),
      for (final phone in _createPhones)
        DemoMember(
          id: phone,
          name: phone,
          avatar: DemoData.avatars[phone.hashCode.abs() % DemoData.avatars.length],
        ),
    ];
    final group = DemoGroup(
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
    _groups = [group, ..._groups];
    resetCreate(notify: false);
    notifyListeners();
    return group;
  }

  void updateImage(String groupId, String url) {
    _groups = [
      for (final group in _groups)
        if (group.id == groupId) group.copyWith(image: url) else group,
    ];
    notifyListeners();
  }

  String? addMember(String groupId, String phone, L10n l10n) {
    final group = byId(groupId);
    if (group.people.any((person) => person.id == phone || person.name == phone)) {
      return l10n.phoneAlreadyAdded;
    }
    final member = DemoMember(
      id: phone,
      name: phone,
      avatar: DemoData.avatars[phone.hashCode.abs() % DemoData.avatars.length],
    );
    _groups = [
      for (final item in _groups)
        if (item.id == groupId)
          item.copyWith(people: [...item.people, member])
        else
          item,
    ];
    notifyListeners();
    return null;
  }

  void removeMember(String groupId, DemoMember person) {
    if (person.role == GroupRole.owner) return;
    _groups = [
      for (final item in _groups)
        if (item.id == groupId)
          item.copyWith(people: item.people.where((member) => member.id != person.id).toList())
        else
          item,
    ];
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

    final result = await unreadCounts.fetchCounts();
    if (token != _epoch) {
      _finishInitialLoad();
      return;
    }
    result.fold<void>(
      (failure) {
        _errorMessage = failure.message;
      },
      applyCounts,
    );

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
        return false;
      },
      (read) {
        _unreadGroupCount = read.unreadGroupCount;
        _groups = [
          for (final group in _groups)
            if (group.id == read.groupId) group.copyWith(unread: read.unreadCount) else group,
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
}
