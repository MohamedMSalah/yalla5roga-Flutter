import 'package:yalla_5roga/core/demo/demo_data.dart';
import 'package:yalla_5roga/core/demo/discover_data.dart';
import 'package:yalla_5roga/core/network/mock_repository.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/geocoding_repository.dart';

class GeocodingMockRepository implements GeocodingRepository {
  const GeocodingMockRepository();

  List<GeocodingHit> get _catalog {
    return [
      for (final place in DemoData.catalogPlaces)
        if (place.latitude != null && place.longitude != null)
          GeocodingHit(name: place.name, latitude: place.latitude!, longitude: place.longitude!),
      for (final place in DiscoverData.places)
        if (place.latitude != null && place.longitude != null)
          GeocodingHit(name: place.name, latitude: place.latitude!, longitude: place.longitude!),
    ];
  }

  @override
  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    await mockDelay();
    GeocodingHit? nearest;
    var best = double.infinity;
    for (final place in _catalog) {
      final dx = place.latitude - latitude;
      final dy = place.longitude - longitude;
      final distance = dx * dx + dy * dy;
      if (distance < best) {
        best = distance;
        nearest = place;
      }
    }
    return nearest?.name ?? 'Cairo';
  }

  @override
  Future<List<GeocodingHit>> search(String query) async {
    await mockDelay();
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    final seen = <String>{};
    return [
      for (final place in _catalog)
        if (seen.add(place.name) && place.name.toLowerCase().contains(needle)) place,
    ];
  }
}
