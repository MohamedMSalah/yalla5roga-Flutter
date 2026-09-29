import 'package:flutter/foundation.dart';
import 'package:yalla_5roga/core/demo/discover_data.dart';

class DiscoverProvider extends ChangeNotifier {
  int _filter = 0;

  int get filter => _filter;

  OutingVibe? get vibe => switch (_filter) {
        1 => OutingVibe.food,
        2 => OutingVibe.activity,
        3 => OutingVibe.outdoor,
        4 => OutingVibe.movie,
        _ => null,
      };

  List<SuggestedPlace> get places => DiscoverData.placesFor(vibe);

  List<SuggestedPlace> get featured => [
        for (final place in DiscoverData.featuredPlaces())
          if (vibe == null || place.vibe == vibe) place,
      ];

  SuggestedPlace? findById(String id) {
    for (final place in DiscoverData.places) {
      if (place.id == id) return place;
    }
    return null;
  }

  void setFilter(int value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }
}
