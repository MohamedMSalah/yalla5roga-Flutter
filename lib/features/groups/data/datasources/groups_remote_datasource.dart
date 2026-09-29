import 'package:dio/dio.dart';
import 'package:yalla_5roga/core/constants/api_constants.dart';
import 'package:yalla_5roga/core/error/exceptions.dart';
import 'package:yalla_5roga/core/network/api_client.dart';
import 'package:yalla_5roga/core/network/api_payload.dart';
import 'package:yalla_5roga/features/groups/data/models/group_read_result_model.dart';

abstract class GroupsRemoteDataSource {
  Future<GroupReadResultModel> markRead(String groupId);
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  const GroupsRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<GroupReadResultModel> markRead(String groupId) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiConstants.groupRead(groupId),
      );
      return GroupReadResultModel.fromJson(
        apiPayload(response.data),
        groupId: groupId,
      );
    } on DioException catch (error) {
      if (error.error is AppException) {
        throw error.error as AppException;
      }
      throw ServerException(error.message ?? 'Server error');
    }
  }
}
