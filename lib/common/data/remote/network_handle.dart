import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:robust/common/data/remote/result.dart';
import 'package:robust/common/event_bus.dart';

import 'network.dart';
import 'network_error.dart';

mixin NetworkHandle on $Restpool {
  /// 处理网络请求
  Future<Result<T>> handleRequest<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(Map<String, dynamic> json) fromJson,
    required String endpoint,
  }) async {
    try {
      final response = await request();
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      final networkError = e.toNetworkError();
      eventBus.fire(networkError);
      return Result.error(networkError, e.stackTrace);
    } catch (e, stackTrace) {
      final networkError = _convertToNetworkError(e);
      eventBus.fire(networkError);
      return Result.error(networkError, stackTrace);
    }
  }

  /// 处理成功响应
  Result<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    try {
      final data = response.data as Map<String, dynamic>;
      return Result.success(fromJson(data));
    } catch (e) {
      return Result.error(
        NetworkError(
          code: 500,
          message: 'Response data parsing failed',
          description: e.toString(),
        ),
        StackTrace.current,
      );
    }
  }

  /// 将通用异常转换为 NetworkError
  NetworkError _convertToNetworkError(dynamic error) {
    return switch (error) {
      SocketException _ => NetworkError(
          code: 101,
          message: 'Network unavailable',
          description: error.toString(),
        ),
      TimeoutException _ => NetworkError(
          code: 102,
          message: 'Request timeout',
          description: error.toString(),
        ),
      _ => NetworkError(
          code: 100,
          message: 'Unknown error occurred',
          description: error.toString(),
        ),
    };
  }
}

/// DioException 扩展方法
extension DioExceptionExtension on DioException {
  NetworkError toNetworkError() {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return NetworkError(
          code: 301,
          message: 'Connection timeout',
          description: message,
        );
      case DioExceptionType.sendTimeout:
        return NetworkError(
          code: 302,
          message: 'Send timeout',
          description: message,
        );
      case DioExceptionType.receiveTimeout:
        return NetworkError(
          code: 303,
          message: 'Receive timeout',
          description: message,
        );
      case DioExceptionType.badCertificate:
        return NetworkError(
          code: 304,
          message: 'Bad certificate',
          description: message,
        );
      case DioExceptionType.badResponse:
        return _handleResponseError(response!);
      case DioExceptionType.cancel:
        return NetworkError(
          code: 306,
          message: 'Request cancelled',
          description: message,
        );
      case DioExceptionType.connectionError:
        return NetworkError(
          code: 307,
          message: 'Connection error',
          description: message,
        );
      case DioExceptionType.unknown:
        return NetworkError(
          code: 310,
          message: 'Unknown error',
          description: message ?? 'No additional information',
        );
    }
  }

  NetworkError _handleResponseError(Response response) {
    final statusCode = response.statusCode ?? 500;
    final errorMessage = switch (statusCode) {
      400 => 'Bad request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Resource not found',
      422 => 'Validation error',
      500 => 'Internal server error',
      503 => 'Service unavailable',
      _ => 'HTTP error $statusCode',
    };

    return NetworkError(
      code: statusCode,
      message: errorMessage,
      description: response.statusMessage,
    );
  }
}
