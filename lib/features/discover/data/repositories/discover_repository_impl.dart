import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/network_info.dart';
import 'package:yalla_5roga/core/network/remote_guard.dart';
import 'package:yalla_5roga/features/discover/data/datasources/discover_remote_datasource.dart';
import 'package:yalla_5roga/features/discover/domain/entities/suggested_place.dart';
import 'package:yalla_5roga/features/discover/domain/repositories/discover_repository.dart';
import 'package:yalla_5roga/features/outings/domain/entities/place.dart';

class DiscoverRepositoryImpl implements DiscoverRepository {
  const DiscoverRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final DiscoverRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<SuggestedPlace>>> getPlaces({OutingVibe? vibe}) {
    return guardRemote(networkInfo, () => remote.getPlaces(vibe: vibe));
  }

  @override
  Future<Either<Failure, List<SuggestedPlace>>> getFeaturedPlaces() {
    return guardRemote(networkInfo, remote.getFeaturedPlaces);
  }

  @override
  Future<Either<Failure, SuggestedPlace>> getPlace(String placeId) {
    return guardRemote(networkInfo, () => remote.getPlace(placeId));
  }

  @override
  List<Place> catalogPlaces() => remote.catalogPlaces();
}
