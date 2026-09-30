import 'package:yalla_5roga/features/outings/domain/entities/place_location.dart';

/// Canonical place used by outings, votes, catalogs, and maps.
class Place {
  const Place({
    required this.name,
    required this.area,
    this.id = '',
    this.latitude,
    this.longitude,
  });

  /// Stable id when known; otherwise [placeId] derives a slug from [name].
  final String id;
  final String name;
  final String area;
  final double? latitude;
  final double? longitude;

  String get placeId => id.isNotEmpty ? id : slugForName(name);

  bool get hasCoordinates => latitude != null && longitude != null;

  PlaceLocation toLocation() => PlaceLocation(
        name: name,
        area: area,
        latitude: latitude,
        longitude: longitude,
      );

  Place copyWith({
    String? id,
    String? name,
    String? area,
    double? latitude,
    double? longitude,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': placeId,
        'name': name,
        'area': area,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      area: json['area'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  static String slugForName(String name) {
    final lower = name.toLowerCase().trim();
    if (lower.contains('brunch')) return 'brunch-room';
    if (lower.contains('lucille')) return 'lucilles';
    if (lower.contains('tap')) return 'tap-east';
    if (lower.contains('zed')) return 'zed-park';
    if (lower.contains('pasta') || lower.contains("o's")) return 'os-pasta';
    if (lower.contains('left bank')) return 'left-bank';
    if (lower.contains('festival')) return 'cairo-festival';
    return lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
  }

  @override
  bool operator ==(Object other) {
    return other is Place && other.placeId == placeId;
  }

  @override
  int get hashCode => placeId.hashCode;
}

/// Backward-compatible alias used across existing UI.
typedef OutingPlace = Place;
