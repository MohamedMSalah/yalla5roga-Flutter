import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalla_5roga/core/constants/app_constants.dart';
import 'package:yalla_5roga/core/demo/demo_data.dart';

class SavedOuting {
  const SavedOuting({
    required this.id,
    required this.title,
    required this.image,
    required this.location,
  });

  final String id;
  final String title;
  final String image;
  final OutingLocation location;

  factory SavedOuting.fromEvent(HeroSlide event) {
    return SavedOuting(
      id: event.id,
      title: event.title,
      image: event.image,
      location: event.location ??
          OutingLocation(name: event.meta.split('·').first.trim()),
    );
  }

  factory SavedOuting.fromJson(Map<String, dynamic> json) {
    return SavedOuting(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      location: OutingLocation.fromJson(
        (json['location'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'location': location.toJson(),
      };
}

class OutingDraft {
  const OutingDraft({
    required this.id,
    required this.title,
    required this.image,
    required this.location,
    required this.date,
    required this.hour,
    required this.minute,
    required this.vibe,
    this.groupId,
    this.occasion = OutingOccasion.none,
    this.specialEvent = false,
    this.guestIds = const [],
  });

  final String id;
  final String title;
  final String image;
  final OutingLocation location;
  final DateTime date;
  final int hour;
  final int minute;
  final int vibe;
  final String? groupId;
  final OutingOccasion occasion;
  final bool specialEvent;
  final List<String> guestIds;

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  factory OutingDraft.fromJson(Map<String, dynamic> json) {
    return OutingDraft(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      location: OutingLocation.fromJson(
        (json['location'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      hour: json['hour'] as int? ?? 11,
      minute: json['minute'] as int? ?? 30,
      vibe: json['vibe'] as int? ?? 0,
      groupId: json['groupId'] as String?,
      occasion: OutingOccasion.values.firstWhere(
        (item) => item.name == json['occasion'],
        orElse: () => OutingOccasion.none,
      ),
      specialEvent: json['specialEvent'] as bool? ?? false,
      guestIds: [
        for (final item in json['guestIds'] as List? ?? const [])
          if (item is String) item,
      ],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'location': location.toJson(),
        'date': date.toIso8601String(),
        'hour': hour,
        'minute': minute,
        'vibe': vibe,
        'groupId': groupId,
        'occasion': occasion.name,
        'specialEvent': specialEvent,
        'guestIds': guestIds,
      };
}

class SavedItem {
  const SavedItem.bookmark(this.outing)
      : draft = null,
        kind = SavedKind.bookmark;

  const SavedItem.draft(this.draft)
      : outing = null,
        kind = SavedKind.draft;

  final SavedKind kind;
  final SavedOuting? outing;
  final OutingDraft? draft;

  bool get isDraft => kind == SavedKind.draft;

  String get id => draft?.id ?? outing!.id;

  String get title => draft?.title ?? outing!.title;

  String get image => draft?.image ?? outing!.image;

  OutingLocation get location => draft?.location ?? outing!.location;
}

enum SavedKind { bookmark, draft }

class SavedOutingsProvider extends ChangeNotifier {
  SavedOutingsProvider(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;
  var _saved = <SavedOuting>[];
  var _drafts = <OutingDraft>[];
  int _tab = 0;

  List<SavedOuting> get saved => List.unmodifiable(_saved);

  List<OutingDraft> get drafts => List.unmodifiable(_drafts);

  List<SavedItem> get items => [
        for (final draft in _drafts) SavedItem.draft(draft),
        for (final outing in _saved) SavedItem.bookmark(outing),
      ];

  List<SavedItem> get visible => showingDrafts
      ? [for (final draft in _drafts) SavedItem.draft(draft)]
      : items;

  int get totalCount => _saved.length + _drafts.length;

  int get tab => _tab;

  bool get showingDrafts => _tab == 1;

  void setTab(int value) {
    if (_tab == value) return;
    _tab = value;
    notifyListeners();
  }

  bool isSaved(String id) => _saved.any((outing) => outing.id == id);

  Future<bool> toggle(HeroSlide event) async {
    if (isSaved(event.id)) {
      _saved = _saved.where((outing) => outing.id != event.id).toList();
      await _persist();
      notifyListeners();
      return false;
    }
    _saved = [SavedOuting.fromEvent(event), ..._saved];
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> removeSaved(String id) async {
    _saved = _saved.where((outing) => outing.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> saveDraft(OutingDraft draft) async {
    _drafts = [draft, ..._drafts.where((item) => item.id != draft.id)];
    await _persistDrafts();
    notifyListeners();
  }

  Future<void> removeDraft(String id) async {
    _drafts = _drafts.where((item) => item.id != id).toList();
    await _persistDrafts();
    notifyListeners();
  }

  Future<void> remove(SavedItem item) {
    return item.isDraft ? removeDraft(item.id) : removeSaved(item.id);
  }

  void _load() {
    try {
      final savedRaw = _prefs.getString(AppConstants.savedOutingsKey);
      if (savedRaw != null && savedRaw.isNotEmpty) {
        final decoded = jsonDecode(savedRaw);
        if (decoded is List) {
          _saved = [
            for (final item in decoded)
              if (item is Map) SavedOuting.fromJson(item.cast<String, dynamic>()),
          ];
        }
      }
      final draftRaw = _prefs.getString(AppConstants.outingDraftsKey);
      if (draftRaw == null || draftRaw.isEmpty) return;
      final decoded = jsonDecode(draftRaw);
      if (decoded is! List) return;
      _drafts = [
        for (final item in decoded)
          if (item is Map) OutingDraft.fromJson(item.cast<String, dynamic>()),
      ];
    } catch (_) {
      _saved = [];
      _drafts = [];
    }
  }

  Future<void> _persist() {
    return _prefs.setString(
      AppConstants.savedOutingsKey,
      jsonEncode(_saved.map((outing) => outing.toJson()).toList()),
    );
  }

  Future<void> _persistDrafts() {
    return _prefs.setString(
      AppConstants.outingDraftsKey,
      jsonEncode(_drafts.map((draft) => draft.toJson()).toList()),
    );
  }
}
