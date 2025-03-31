import 'package:dio/dio.dart';

import 'network_handle.dart';
import 'result.dart';

/*
 *  curl --request GET \
 *   --url 'https://api.github.com/v2' \
 *   --header 'Authorization: Bearer <YOUR_ACCESS_TOKEN>' \
 *   --header 'accept: application/json'
 */
abstract class $Restpool {
  /// 获取当前请求头
  Map<String, dynamic> get headers;

  /// 添加/更新请求头
  void updateHeaders(Map<String, dynamic> newHeaders);

  /// GET 请求
  Future<Result<T>> get<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// POST 请求
  Future<Result<T>> post<T>({
    required String endpoint,
    required dynamic data,
    required T Function(Map<String, dynamic> json) fromJson,
    Options? options,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  });

  /// PUT 请求
  Future<Result<T>> put<T>({
    required String endpoint,
    required dynamic data,
    required T Function(Map<String, dynamic> json) fromJson,
    Options? options,
    CancelToken? cancelToken,
  });

  /// DELETE 请求
  Future<Result<T>> delete<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// 上传文件
  Future<Result<T>> upload<T>({
    required String endpoint,
    required List<MultipartFile> files,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? data,
    Options? options,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  });
}

class Restpool extends $Restpool with NetworkHandle {
  final Dio _dio;

  Restpool(this._dio) {
    _dio.options.headers = headers;
    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }

  @override
  Map<String, dynamic> get headers => {
        'accept': 'application/json',
        'content-type': 'application/json',
      };

  @override
  void updateHeaders(Map<String, dynamic> newHeaders) {
    _dio.options.headers.addAll(newHeaders);
  }

  @override
  Future<Result<T>> get<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return handleRequest(
      request: () => _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
      endpoint: endpoint,
    );
  }

  @override
  Future<Result<T>> post<T>({
    required String endpoint,
    required dynamic data,
    required T Function(Map<String, dynamic> json) fromJson,
    Options? options,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    return handleRequest(
      request: () => _dio.post(
        endpoint,
        data: data,
        options: options,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
      endpoint: endpoint,
    );
  }

  @override
  Future<Result<T>> put<T>({
    required String endpoint,
    required dynamic data,
    required T Function(Map<String, dynamic> json) fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return handleRequest(
      request: () => _dio.put(
        endpoint,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
      endpoint: endpoint,
    );
  }

  @override
  Future<Result<T>> delete<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return handleRequest(
      request: () => _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
      endpoint: endpoint,
    );
  }

  @override
  Future<Result<T>> upload<T>({
    required String endpoint,
    required List<MultipartFile> files,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? data,
    Options? options,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      ...?data,
      'files': files,
    });
    return handleRequest(
      request: () => _dio.post(
        endpoint,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
      endpoint: endpoint,
    );
  }
}
