import 'package:dio/dio.dart';
import 'package:yalla_5roga/core/constants/api_constants.dart';
import 'package:yalla_5roga/core/error/exceptions.dart';
import 'package:yalla_5roga/core/network/api_client.dart';
import 'package:yalla_5roga/core/network/api_payload.dart';
import 'package:yalla_5roga/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String phone, required String password});

  Future<UserModel> register({
    required String name,
    required String phone,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<UserModel> login({
    required String phone,
    required String password,
  }) {
    return _postUser(ApiConstants.login, {
      'phone': phone,
      'password': password,
    });
  }

  @override
  Future<UserModel> register({
    required String name,
    required String phone,
    required String password,
  }) {
    return _postUser(ApiConstants.register, {
      'name': name,
      'phone': phone,
      'password': password,
    });
  }

  Future<UserModel> _postUser(String path, Map<String, dynamic> data) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(path, data: data);
      return UserModel.fromJson(apiPayload(response.data));
    } on DioException catch (error) {
      if (error.error is AppException) {
        throw error.error as AppException;
      }
      throw ServerException(error.message ?? 'Server error');
    }
  }
}
