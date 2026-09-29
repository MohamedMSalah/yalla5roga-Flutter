class GeocodingHit {
  const GeocodingHit({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final double latitude;
  final double longitude;
}

abstract class GeocodingRepository {
  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  });

  Future<List<GeocodingHit>> search(String query);
}
