import 'package:flutter/foundation.dart';
import 'package:yalla_5roga/core/demo/demo_data.dart';

class OutingsProvider extends ChangeNotifier {
  OutingsProvider() {
    _outings = List.of(DemoData.heroSlides);
  }

  late List<HeroSlide> _outings;
  int _filter = 0;
  int _featuredIndex = 0;
  int _voteIndex = 0;

  static const voteOptions = [
    VoteOption('brunch-room', 3, 60),
    VoteOption('lucilles', 2, 40),
  ];

  static List<OutingPlace> get places => DemoData.catalogPlaces;

  List<HeroSlide> get outings => List.unmodifiable(_outings);

  List<HeroSlide> get filtered {
    final status = OutingStatus.values[_filter.clamp(0, OutingStatus.values.length - 1)];
    return [for (final outing in _outings) if (outing.status == status) outing];
  }

  int get filter => _filter;

  int get featuredIndex => _featuredIndex;

  int get voteIndex => _voteIndex;

  List<HeroSlide> forGroup(String groupId) {
    return _outings.where((outing) => outing.groupId == groupId).toList();
  }

  void setFilter(int value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  void setFeaturedIndex(int value) {
    if (_featuredIndex == value) return;
    _featuredIndex = value;
    notifyListeners();
  }

  void selectVote(int value) {
    if (_voteIndex == value) return;
    _voteIndex = value;
    notifyListeners();
  }

  void add(HeroSlide outing) {
    _outings = [outing, ..._outings];
    notifyListeners();
  }
}

class VoteOption {
  const VoteOption(this.placeId, this.votes, this.percent);

  final String placeId;
  final int votes;
  final int percent;
}
