import 'package:dio/dio.dart';
import 'package:yalla_5roga/core/constants/api_constants.dart';
import 'package:yalla_5roga/core/error/exceptions.dart';
import 'package:yalla_5roga/core/network/api_client.dart';
import 'package:yalla_5roga/core/network/api_payload.dart';
import 'package:yalla_5roga/features/unread/data/models/unread_counts_model.dart';

abstract class UnreadCountsRemoteDataSource {
  Future<UnreadCountsModel> getCounts();
}

class UnreadCountsRemoteDataSourceImpl implements UnreadCountsRemoteDataSource {
  const UnreadCountsRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<UnreadCountsModel> getCounts() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(ApiConstants.unreadCounts);
      return UnreadCountsModel.fromJson(apiPayload(response.data));
    } on DioException catch (error) {
      if (error.error is AppException) {
        throw error.error as AppException;
      }
      throw ServerException(error.message ?? 'Server error');
    }
  }
}
