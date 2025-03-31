import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_error.freezed.dart';

@freezed
abstract class NetworkError with _$NetworkError {
  const factory NetworkError({
    required int code,
    required String message,
    String? description,
  }) = _NetworkError;
}