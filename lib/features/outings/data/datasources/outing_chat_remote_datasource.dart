import 'package:dio/dio.dart';
import 'package:yalla_5roga/core/constants/api_constants.dart';
import 'package:yalla_5roga/core/error/exceptions.dart';
import 'package:yalla_5roga/core/network/api_client.dart';
import 'package:yalla_5roga/core/network/api_payload.dart';
import 'package:yalla_5roga/features/outings/data/models/outing_chat_read_result_model.dart';

abstract class OutingChatRemoteDataSource {
  Future<OutingChatReadResultModel> markRead(String outingId);
}

class OutingChatRemoteDataSourceImpl implements OutingChatRemoteDataSource {
  const OutingChatRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<OutingChatReadResultModel> markRead(String outingId) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiConstants.outingChatRead(outingId),
      );
      return OutingChatReadResultModel.fromJson(
        apiPayload(response.data),
        outingId: outingId,
      );
    } on DioException catch (error) {
      if (error.error is AppException) {
        throw error.error as AppException;
      }
      throw ServerException(error.message ?? 'Server error');
    }
  }
}
