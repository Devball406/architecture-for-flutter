import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:robust/common/data/local/storage.dart';

typedef TokenPair = ({String token, String tokenExpiry});

const TOKEN = 'token';
const TOKEN_Expiry = 'token_expiry';

class RevokeTokenException extends DioException {
  RevokeTokenException({required super.requestOptions});
}

class TokenRefreshInterceptor extends QueuedInterceptor {
  final Dio dio;
  final Local local;
  final bool shouldCleanBeforeReset;
  late final Dio refreshClient;
  late final Dio retryClient;

  /// Create an Auth interceptor
  TokenRefreshInterceptor({
    required this.dio,
    required this.local,
    this.shouldCleanBeforeReset = true,
  }) {
    refreshClient = Dio();
    refreshClient.options = BaseOptions(baseUrl: dio.options.baseUrl);

    retryClient = Dio();
    retryClient.options = BaseOptions(baseUrl: dio.options.baseUrl);
  }

  /*
  4.1. OnRequest 请求
   以下方法将检查 Token 是否有效：
    - 如果有效，它会将请求发送到服务器，并在标头中使用当前访问令牌。
    - 否则，它将向服务器发送刷新请求，并尝试续订缓存的令牌。
  */
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final tokenPair = await _getTokenPair();
      if (tokenPair == null) {
        return handler.next(options);
      }
      final isValidToken = await _isValidToken;
      if (isValidToken) {
        options.headers.addAll(await _buildHeaders());
        return handler.next(options);
      } else {
        final newTokenPair = await _refresh(
          options: options,
          tokenPair: tokenPair,
        );
        if (newTokenPair == null) {
          return handler.reject(
            RevokeTokenException(requestOptions: options),
            true,
          );
        }
        options.headers.addAll(await _buildHeaders());
        return handler.next(options);
      }
    } catch (_) {
      return handler.reject(
        RevokeTokenException(requestOptions: options),
        true,
      );
    }
  }

  /*
  4.2. OnError 错误
  - 如果您还记得，我们已经定义了 RevokeTokenException。此异常允许我们检测是否应该使用户的会话过期。
  - 如果错误的状态代码不是 401，它将跳过所有进程，并将向数据层（或您处理 HTTP 请求的位置）引发异常。
  - 我们再次重复 access token 的验证。它确保，尽管我们从不同的端点收到许多 401 错误，但只有第一个错误会起作用（将尝试刷新令牌）。对于所有其他请求，将仅应用重试机制。
  */
  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err is RevokeTokenException) {
      /// call the session expire logic for your state management
      return handler.reject(err);
    }

    if (!shouldRefreshToken(err.response)) {
      return handler.next(err);
    }

    final isAccessValid = await _isValidToken;
    final tokenPair = await _getTokenPair();

    if (tokenPair == null) {
      return handler.reject(err);
    }

    try {
      if (isAccessValid) {
        final previousRequest = await _retry(err.requestOptions);
        return handler.resolve(previousRequest);
      } else {
        await _refresh(options: err.requestOptions, tokenPair: tokenPair);
        final previousRequest = await _retry(err.requestOptions);
        return handler.resolve(previousRequest);
      }
    } on RevokeTokenException {
      /// call the session expire logic for your state management
      return handler.reject(err);
    } on DioException catch (err) {
      return handler.next(err);
    }
  }

  Future<TokenPair?> _getTokenPair() async {
    String token = local.get(TOKEN);
    String tokenExpiry = local.get(TOKEN_Expiry);
    if (token.isNotEmpty && tokenExpiry.isNotEmpty) {
      return (token: token, tokenExpiry: tokenExpiry);
    }
    return null;
  }

  Future<void> _saveTokenPair(TokenPair tokenPair) async {
    local.put(TOKEN, tokenPair.token);
    local.put(TOKEN_Expiry, tokenPair.tokenExpiry);
  }

  Future<void> _clearTokenPair() async {
    await local.delete(TOKEN);
    await local.delete(TOKEN_Expiry);
  }

  Future<Map<String, dynamic>> _buildHeaders() async {
    final tokenPair = await _getTokenPair();
    return {
      'Authorization': 'Bearer ${tokenPair!.token}',
    };
  }

  /// Check if the token pair should be refreshed
  @visibleForTesting
  @pragma('vm:prefer-inline')
  bool shouldRefreshToken<R>(Response<R>? response) =>
      response?.statusCode == 401;

  Future<bool> get _isValidToken async {
    final tokenPair = await _getTokenPair();

    if (tokenPair == null) {
      return false;
    }
    final decodedJwt = JWT.decode(tokenPair.token);
    final expirationTimeEpoch = decodedJwt.payload['exp'];
    final expirationDateTime =
        DateTime.fromMillisecondsSinceEpoch(expirationTimeEpoch * 1000);

    ///marginOfErrorInMilliseconds 的值。这是一个 error 值，用于确保在发送请求时不会过期。
    final marginOfErrorInMilliseconds = 1000; // error 1 seconds
    final addedMarginTime = Duration(milliseconds: marginOfErrorInMilliseconds);
    return DateTime.now().add(addedMarginTime).isBefore(expirationDateTime);
  }

  //这是一个基本实现，在服务器的帮助下刷新令牌并将其保存在本地存储中。
  Future<TokenPair?> _refresh({
    required RequestOptions options,
    TokenPair? tokenPair,
  }) async {
    if (tokenPair == null) {
      throw RevokeTokenException(requestOptions: options);
    }
    try {
      /// it will be changed based on your project
      String user = 'user';
      String password = 'password';
      String auth = 'Basic ${base64Encode(utf8.encode('$user:$password'))}';
      Options options = Options(headers: {'authorization': auth});

      final response = await refreshClient.get(
        '/art/token',
        queryParameters: {'id': 'client_uuid'},
        options: options
      );

      final TokenPair newTokenPair = (
        token: response.data[TOKEN],
        tokenExpiry: response.data[TOKEN_Expiry],
      );

      if (shouldCleanBeforeReset) {
        await _clearTokenPair();
      }
      await _saveTokenPair(newTokenPair);
      return newTokenPair;
    } catch (_) {
      await _clearTokenPair();
      throw RevokeTokenException(requestOptions: options);
    }
  }

  /*
    3.3. 请求重试机制
    当我们在刷新 token 后需要重试请求时，我们将使用以下函数。
  */
  Future<Response<R>> _retry<R>(
    RequestOptions requestOptions,
  ) async {
    return retryClient.request<R>(
      requestOptions.path,
      cancelToken: requestOptions.cancelToken,
      data: requestOptions.data is FormData
          ? (requestOptions.data as FormData).clone()
          : requestOptions.data,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        extra: requestOptions.extra,
        headers: requestOptions.headers..addAll(await _buildHeaders()),
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        validateStatus: requestOptions.validateStatus,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        requestEncoder: requestOptions.requestEncoder,
        responseDecoder: requestOptions.responseDecoder,
        listFormat: requestOptions.listFormat,
      ),
    );
  }
}
