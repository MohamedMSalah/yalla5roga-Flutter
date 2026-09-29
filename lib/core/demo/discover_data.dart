import 'package:yalla_5roga/core/demo/demo_data.dart';
import 'package:yalla_5roga/core/localization/l10n.dart';

enum OutingVibe { food, activity, outdoor, movie }

enum PriceLevel { free, budget, moderate, expensive, luxury }

enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class DiscoverPlaceImage {
  const DiscoverPlaceImage({
    required this.imageUrl,
    this.caption,
  });

  final String imageUrl;
  final String? caption;
}

class DiscoverPlaceHours {
  const DiscoverPlaceHours({
    required this.day,
    this.opensAt,
    this.closesAt,
    this.isClosed = false,
  });

  final Weekday day;
  final String? opensAt;
  final String? closesAt;
  final bool isClosed;
}

class DiscoverPlacePrice {
  const DiscoverPlacePrice({
    required this.labelKey,
    required this.amount,
    this.currency = 'EGP',
  });

  final String labelKey;
  final double amount;
  final String currency;
}

class SuggestedPlace {
  const SuggestedPlace({
    required this.id,
    required this.name,
    required this.area,
    required this.vibe,
    required this.coverImageUrl,
    required this.descriptionKey,
    this.priceLevel = PriceLevel.moderate,
    this.priceMin,
    this.priceMax,
    this.currency = 'EGP',
    this.latitude,
    this.longitude,
    this.featured = false,
    this.images = const [],
    this.hours = const [],
    this.prices = const [],
  });

  final String id;
  final String name;
  final String area;
  final OutingVibe vibe;
  final String coverImageUrl;
  final String descriptionKey;
  final PriceLevel priceLevel;
  final double? priceMin;
  final double? priceMax;
  final String currency;
  final double? latitude;
  final double? longitude;
  final bool featured;
  final List<DiscoverPlaceImage> images;
  final List<DiscoverPlaceHours> hours;
  final List<DiscoverPlacePrice> prices;

  /// Compatibility alias used by older widgets.
  String get imageUrl => coverImageUrl;

  OutingPlace toOutingPlace() => OutingPlace(
        name: name,
        area: area,
        latitude: latitude,
        longitude: longitude,
      );

  String localizedName(L10n l10n) => l10n.suggestedPlaceName(id);

  String localizedArea(L10n l10n) => l10n.suggestedArea(area);

  String localizedDescription(L10n l10n) => l10n.discoverPlaceDescription(descriptionKey);
}

class DiscoverData {
  const DiscoverData._();

  static const _weekHours = [
    DiscoverPlaceHours(day: Weekday.monday, opensAt: '10:00', closesAt: '22:00'),
    DiscoverPlaceHours(day: Weekday.tuesday, opensAt: '10:00', closesAt: '22:00'),
    DiscoverPlaceHours(day: Weekday.wednesday, opensAt: '10:00', closesAt: '22:00'),
    DiscoverPlaceHours(day: Weekday.thursday, opensAt: '10:00', closesAt: '23:00'),
    DiscoverPlaceHours(day: Weekday.friday, opensAt: '10:00', closesAt: '00:00'),
    DiscoverPlaceHours(day: Weekday.saturday, opensAt: '10:00', closesAt: '00:00'),
    DiscoverPlaceHours(day: Weekday.sunday, opensAt: '10:00', closesAt: '22:00'),
  ];

  static const places = [
    SuggestedPlace(
      id: 'zed-park',
      name: 'ZED Park',
      area: 'New Cairo',
      vibe: OutingVibe.outdoor,
      coverImageUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=800&q=85',
      descriptionKey: 'zed-park',
      priceLevel: PriceLevel.budget,
      priceMin: 0,
      priceMax: 150,
      latitude: 30.0215,
      longitude: 31.4952,
      featured: true,
      images: [
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=800&q=85'),
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=85'),
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=85'),
      ],
      hours: _weekHours,
      prices: [
        DiscoverPlacePrice(labelKey: 'entry', amount: 50),
        DiscoverPlacePrice(labelKey: 'parking', amount: 20),
      ],
    ),
    SuggestedPlace(
      id: 'brunch-room',
      name: 'The Brunch Room',
      area: 'Maadi',
      vibe: OutingVibe.food,
      coverImageUrl: 'https://images.unsplash.com/photo-1533777324565-a040eb52facd?auto=format&fit=crop&w=800&q=85',
      descriptionKey: 'brunch-room',
      priceLevel: PriceLevel.moderate,
      priceMin: 180,
      priceMax: 450,
      latitude: 29.9602,
      longitude: 31.2589,
      featured: true,
      images: [
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1533777324565-a040eb52facd?auto=format&fit=crop&w=800&q=85'),
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=800&q=85'),
      ],
      hours: _weekHours,
      prices: [
        DiscoverPlacePrice(labelKey: 'brunch_set', amount: 320),
        DiscoverPlacePrice(labelKey: 'coffee', amount: 85),
      ],
    ),
    SuggestedPlace(
      id: 'tap-east',
      name: 'The Tap East',
      area: 'Heliopolis',
      vibe: OutingVibe.activity,
      coverImageUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=85',
      descriptionKey: 'tap-east',
      priceLevel: PriceLevel.moderate,
      priceMin: 200,
      priceMax: 600,
      latitude: 30.0917,
      longitude: 31.3244,
      featured: true,
      images: [
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=85'),
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=85'),
      ],
      hours: _weekHours,
      prices: [
        DiscoverPlacePrice(labelKey: 'games', amount: 250),
        DiscoverPlacePrice(labelKey: 'drinks', amount: 120),
      ],
    ),
    SuggestedPlace(
      id: 'cfc',
      name: 'Cairo Festival City',
      area: 'New Cairo',
      vibe: OutingVibe.activity,
      coverImageUrl: 'https://images.unsplash.com/photo-1579532537598-459ecdaf39cc?auto=format&fit=crop&w=800&q=85',
      descriptionKey: 'cfc',
      priceLevel: PriceLevel.moderate,
      priceMin: 100,
      priceMax: 800,
      latitude: 30.0285,
      longitude: 31.4073,
      featured: true,
      images: [
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1579532537598-459ecdaf39cc?auto=format&fit=crop&w=800&q=85'),
      ],
      hours: _weekHours,
      prices: [
        DiscoverPlacePrice(labelKey: 'bowling', amount: 180),
        DiscoverPlacePrice(labelKey: 'food', amount: 250),
      ],
    ),
    SuggestedPlace(
      id: 'vox-cfc',
      name: 'VOX Cinemas',
      area: 'Cairo Festival City',
      vibe: OutingVibe.movie,
      coverImageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=800&q=85',
      descriptionKey: 'vox-cfc',
      priceLevel: PriceLevel.moderate,
      priceMin: 150,
      priceMax: 350,
      latitude: 30.0285,
      longitude: 31.4073,
      featured: true,
      images: [
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=800&q=85'),
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=800&q=85'),
      ],
      hours: _weekHours,
      prices: [
        DiscoverPlacePrice(labelKey: 'ticket', amount: 180),
        DiscoverPlacePrice(labelKey: 'combo', amount: 120),
      ],
    ),
    SuggestedPlace(
      id: 'sequoia',
      name: 'Sequoia',
      area: 'Zamalek',
      vibe: OutingVibe.food,
      coverImageUrl: 'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=800&q=85',
      descriptionKey: 'sequoia',
      priceLevel: PriceLevel.expensive,
      priceMin: 400,
      priceMax: 1200,
      latitude: 30.0730,
      longitude: 31.2240,
      images: [
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=800&q=85'),
      ],
      hours: _weekHours,
      prices: [
        DiscoverPlacePrice(labelKey: 'dinner', amount: 650),
      ],
    ),
    SuggestedPlace(
      id: 'azhar-park',
      name: 'Al Azhar Park',
      area: 'Islamic Cairo',
      vibe: OutingVibe.outdoor,
      coverImageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=85',
      descriptionKey: 'azhar-park',
      priceLevel: PriceLevel.budget,
      priceMin: 20,
      priceMax: 100,
      latitude: 30.0408,
      longitude: 31.2647,
      images: [
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=85'),
      ],
      hours: _weekHours,
      prices: [
        DiscoverPlacePrice(labelKey: 'entry', amount: 20),
      ],
    ),
    SuggestedPlace(
      id: 'zawya',
      name: 'Zawya',
      area: 'Downtown',
      vibe: OutingVibe.movie,
      coverImageUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=800&q=85',
      descriptionKey: 'zawya',
      priceLevel: PriceLevel.budget,
      priceMin: 80,
      priceMax: 150,
      latitude: 30.0475,
      longitude: 31.2384,
      images: [
        DiscoverPlaceImage(imageUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=800&q=85'),
      ],
      hours: [
        DiscoverPlaceHours(day: Weekday.monday, isClosed: true),
        DiscoverPlaceHours(day: Weekday.tuesday, opensAt: '16:00', closesAt: '23:00'),
        DiscoverPlaceHours(day: Weekday.wednesday, opensAt: '16:00', closesAt: '23:00'),
        DiscoverPlaceHours(day: Weekday.thursday, opensAt: '16:00', closesAt: '23:00'),
        DiscoverPlaceHours(day: Weekday.friday, opensAt: '14:00', closesAt: '00:00'),
        DiscoverPlaceHours(day: Weekday.saturday, opensAt: '14:00', closesAt: '00:00'),
        DiscoverPlaceHours(day: Weekday.sunday, opensAt: '14:00', closesAt: '23:00'),
      ],
      prices: [
        DiscoverPlacePrice(labelKey: 'ticket', amount: 100),
      ],
    ),
  ];

  static SuggestedPlace placeById(String id) {
    return places.firstWhere((place) => place.id == id, orElse: () => places.first);
  }

  static List<SuggestedPlace> featuredPlaces() {
    return places.where((place) => place.featured).toList();
  }

  static List<SuggestedPlace> placesFor(OutingVibe? vibe) {
    if (vibe == null) return places;
    return places.where((place) => place.vibe == vibe).toList();
  }

  static List<OutingPlace> catalogPlaces() {
    final seen = <String>{};
    final result = <OutingPlace>[];
    for (final place in [...DemoData.catalogPlaces, ...places.map((item) => item.toOutingPlace())]) {
      if (seen.add('${place.name}|${place.area}')) result.add(place);
    }
    return result;
  }
}
