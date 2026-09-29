import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalla_5roga/core/constants/app_constants.dart';
import 'package:yalla_5roga/core/error/exceptions.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._prefs);

  final SharedPreferences _prefs;

  /// Flip to true after POST /auth/firebase returns an app JWT.
  static const attachBackendJwt = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (attachBackendJwt) {
      final token = _prefs.getString(AppConstants.tokenKey);
      if (token != null && token.isNotEmpty && token != AppConstants.demoToken) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}

class AppLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[DIO] ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[DIO] Error ${err.response?.statusCode} ${err.requestOptions.uri}');
    }
    handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = _extractMessage(err);

    final AppException exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        NetworkException(message),
      _ => switch (err.response?.statusCode) {
          401 || 403 => AuthException(message),
          _ => ServerException(message),
        },
    };

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  String _extractMessage(DioException err) {
    final data = err.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return err.message ?? 'Unexpected error';
  }
}
