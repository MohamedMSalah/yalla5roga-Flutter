import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/features/discover/domain/entities/suggested_place.dart';
import 'package:yalla_5roga/features/outings/domain/entities/place.dart';

abstract class DiscoverRepository {
  Future<Either<Failure, List<SuggestedPlace>>> getPlaces({OutingVibe? vibe});

  Future<Either<Failure, List<SuggestedPlace>>> getFeaturedPlaces();

  Future<Either<Failure, SuggestedPlace>> getPlace(String placeId);

  List<Place> catalogPlaces();
}
