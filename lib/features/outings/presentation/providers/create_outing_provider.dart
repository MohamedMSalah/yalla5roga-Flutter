import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yalla_5roga/core/demo/demo_data.dart';
import 'package:yalla_5roga/core/demo/discover_data.dart';
import 'package:yalla_5roga/core/localization/l10n.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/pick_location_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/saved_outings_provider.dart';

class CreateOutingProvider extends ChangeNotifier {
  CreateOutingProvider({
    required this._groups,
    DemoGroup? group,
    SuggestedPlace? suggestedPlace,
    this.saved,
    this.draft,
    bool specialEvent = false,
  }) : _group = group,
       _groupLocked = group != null,
       _specialEvent = specialEvent || (draft?.specialEvent ?? false),
       _draftId = draft?.id ?? 'draft-${DateTime.now().millisecondsSinceEpoch}' {
    nameController = TextEditingController(text: saved?.title ?? draft?.title ?? '');
    customPlaceController = TextEditingController();
    customPlaceController.addListener(_onCustomPlaceChanged);
    if (_specialEvent) _occasion = OutingOccasion.birthday;
    if (suggestedPlace != null) {
      _place = suggestedPlace.toOutingPlace();
      _vibe = suggestedPlace.vibe.index;
      _image = suggestedPlace.coverImageUrl;
    }
    if (saved != null) {
      nameController.text = saved!.title;
      _image = saved!.image;
      _applyLocation(saved!.location);
    }
    if (draft != null) {
      nameController.text = draft!.title;
      _image = draft!.image;
      _vibe = draft!.vibe;
      _time = draft!.time;
      _date = draft!.date;
      _occasion = draft!.occasion == OutingOccasion.none && _specialEvent
          ? OutingOccasion.birthday
          : draft!.occasion;
      _guestIds.addAll(draft!.guestIds);
      if (draft!.groupId != null) {
        _group = _groups.cast<DemoGroup?>().firstWhere(
          (item) => item?.id == draft!.groupId,
          orElse: () => group,
        );
      }
      _applyLocation(draft!.location);
    }
    _date = clampDate(_date);
  }

  final List<DemoGroup> _groups;
  final SavedOuting? saved;
  final OutingDraft? draft;
  final bool _specialEvent;
  final bool _groupLocked;
  final String _draftId;
  final _guestIds = <String>{};

  late final TextEditingController nameController;
  late final TextEditingController customPlaceController;

  int _step = 0;
  int _vibe = 0;
  bool _letVote = true;
  String? _image;
  DemoGroup? _group;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 11, minute: 30);
  OutingPlace? _place;
  double? _customLatitude;
  double? _customLongitude;
  OutingOccasion _occasion = OutingOccasion.none;
  Locale _locale = const Locale('en');

  int get step => _step;

  int get vibe => _vibe;

  bool get letVote => _letVote;

  String? get image => _image;

  DemoGroup? get group => _group;

  DateTime get date => _date;

  TimeOfDay get time => _time;

  OutingPlace? get place => _place;

  double? get customLatitude => _customLatitude;

  double? get customLongitude => _customLongitude;

  OutingOccasion get occasion => _occasion;

  bool get specialEvent => _specialEvent;

  bool get groupLocked => _groupLocked;

  Set<String> get guestIds => _guestIds;

  List<DemoGroup> get groups => List.unmodifiable(_groups);

  List<DemoMember> get contacts => DemoData.groupContacts;

  bool get allGuestsSelected => _guestIds.length == contacts.length;

  DateTime get minDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get maxDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, now.day);
  }

  String get resolvedImage => _image ?? (_specialEvent ? DemoData.specialEventImage(_occasion) : '');

  bool get isCustomPlace => customPlaceController.text.trim().isNotEmpty;

  bool get customPlacePinned => _customLatitude != null && _customLongitude != null;

  OutingLocation? get selectedLocation {
    if (isCustomPlace) {
      return OutingLocation(
        name: customPlaceController.text.trim(),
        latitude: _customLatitude,
        longitude: _customLongitude,
      );
    }
    return _place?.toLocation();
  }

  String get formattedDate => DateFormat('EEE, d MMM', _locale.languageCode).format(_date).toUpperCase();

  String get shortDate => DateFormat('d MMM', _locale.languageCode).format(_date);

  String get formattedTime {
    final value = DateTime(0, 1, 1, _time.hour, _time.minute);
    return DateFormat('h:mm a', _locale.languageCode).format(value);
  }

  String get locationLabel {
    if (customPlaceController.text.trim().isNotEmpty) return customPlaceController.text.trim();
    if (_place != null) return '${_place!.name}, ${_place!.area}';
    return '';
  }

  List<String> get guestNames => [
        for (final id in _guestIds)
          if (DemoData.memberById(id) != null) DemoData.memberById(id)!.name,
      ];

  DateTime clampDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (day.isBefore(minDate)) return minDate;
    if (day.isAfter(maxDate)) return maxDate;
    return day;
  }

  void applySuggestionTitle(L10n l10n) {
    _locale = l10n.locale;
    if (nameController.text.trim().isEmpty && !_specialEvent) {
      nameController.text = l10n.defaultOutingName;
    }
  }

  void _applyLocation(OutingLocation location) {
    final match = DiscoverData.catalogPlaces().where(
      (item) => item.name == location.name && (location.area.isEmpty || item.area == location.area),
    );
    if (match.isNotEmpty) {
      _place = match.first;
      return;
    }
    customPlaceController.text = location.label;
    _customLatitude = location.latitude;
    _customLongitude = location.longitude;
  }

  void _onCustomPlaceChanged() {
    if (isCustomPlace && _place != null) {
      _place = null;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void back() {
    if (_step == 0) return;
    _step -= 1;
    notifyListeners();
  }

  String? validateStep(L10n l10n) {
    if (_step == 0) {
      if (nameController.text.trim().isEmpty) return l10n.nameRequired;
      if (!_specialEvent && _image == null) return l10n.photoRequired;
      if (_specialEvent) {
        if (_guestIds.isEmpty) return l10n.guestsRequired;
      } else if (_group == null) {
        return l10n.groupRequired;
      }
    }
    if (_step == 1) {
      if (locationLabel.isEmpty) return l10n.locationRequired;
      if (isCustomPlace && !customPlacePinned) return l10n.pickLocationRequired;
    }
    return null;
  }

  String? next(L10n l10n) {
    final error = validateStep(l10n);
    if (error != null) return error;
    _step += 1;
    notifyListeners();
    return null;
  }

  String? draftError(L10n l10n) {
    if (nameController.text.trim().isEmpty) return l10n.nameRequired;
    if (!_specialEvent && _image == null) return l10n.photoRequired;
    if (locationLabel.isEmpty) return l10n.locationRequired;
    return null;
  }

  void setImage(String path) {
    _image = path;
    notifyListeners();
  }

  void setVibe(int value) {
    _vibe = value;
    notifyListeners();
  }

  void setOccasion(OutingOccasion value) {
    _occasion = value;
    notifyListeners();
  }

  void setLetVote(bool value) {
    _letVote = value;
    notifyListeners();
  }

  void toggleLetVote() => setLetVote(!_letVote);

  void setGroup(DemoGroup value) {
    if (_groupLocked) return;
    _group = value;
    notifyListeners();
  }

  void setDate(DateTime value) {
    _date = clampDate(value);
    notifyListeners();
  }

  void setTime(TimeOfDay value) {
    _time = value;
    notifyListeners();
  }

  void setCatalogPlace(OutingPlace value) {
    _place = value;
    _customLatitude = null;
    _customLongitude = null;
    customPlaceController.clear();
    notifyListeners();
  }

  void applyPickedPlace(PickedPlace picked) {
    _place = null;
    _customLatitude = picked.latitude;
    _customLongitude = picked.longitude;
    customPlaceController.text = picked.name;
    notifyListeners();
  }

  void toggleGuest(String id) {
    if (!_guestIds.add(id)) _guestIds.remove(id);
    notifyListeners();
  }

  void toggleSelectAll() {
    if (allGuestsSelected) {
      _guestIds.clear();
    } else {
      _guestIds
        ..clear()
        ..addAll(contacts.map((person) => person.id));
    }
    notifyListeners();
  }

  OutingDraft toDraft() {
    return OutingDraft(
      id: _draftId,
      title: nameController.text.trim(),
      image: resolvedImage,
      location: selectedLocation ?? OutingLocation(name: locationLabel),
      date: _date,
      hour: _time.hour,
      minute: _time.minute,
      vibe: _vibe,
      groupId: _group?.id,
      occasion: _occasion,
      specialEvent: _specialEvent,
      guestIds: _guestIds.toList(),
    );
  }

  HeroSlide buildOuting() {
    final guests = [
      for (final id in _guestIds)
        if (DemoData.memberById(id) != null) id,
    ];
    return HeroSlide(
      id: 'outing-${DateTime.now().millisecondsSinceEpoch}',
      image: resolvedImage,
      title: nameController.text.trim(),
      meta: '$locationLabel · $formattedTime',
      date: formattedDate,
      time: formattedTime,
      going: _specialEvent ? guests.length : _group!.people.length,
      groupId: _specialEvent ? null : _group!.id,
      location: selectedLocation,
      occasion: _occasion,
      guestIds: guests,
      status: _letVote ? OutingStatus.voting : OutingStatus.upcoming,
    );
  }

  @override
  void dispose() {
    customPlaceController.removeListener(_onCustomPlaceChanged);
    nameController.dispose();
    customPlaceController.dispose();
    super.dispose();
  }
}
