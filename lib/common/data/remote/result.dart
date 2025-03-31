import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<T> with _$Result {
  Result._();

  factory Result.success(T value) = _Success;

  factory Result.error(Object err, [StackTrace? stackTrace]) = _Error;

  factory Result.guard(T Function() callback) {
    try {
      return Result.success(callback.call());
    } catch (err, stack) {
      return Result.error(err, stack);
    }
  }
}

///chain
extension ResultChain<T> on Result<T> {
  bool get isSuccess => this is _Success;

  T get dataOrThrow {
    switch (this) {
      case _Success(:final value):
        return value;
      case _Error(:final err):
        throw err;
    }
  }

  // map
  Result<R> map<R>(R Function(T value) success) {
    switch (this) {
      case _Success(:final value):
        try {
          return Result.success(success(value));
        } catch (err, stack) {
          return Result.error(err, stack);
        }

      case _Error(:final err):
        return Result.error(err);
    }
  }

  R when<R>({
    required R Function(T value) success,
    required R Function(Object err, StackTrace? stackTrace) error,
  }) {
    return switch (this) {
      _Success(:final value) => success.call(value),
      _Error(:final err, :final stackTrace) => error.call(err, stackTrace),
    };
  }

  R? whenOrNull<R>({
    R? Function(T value)? success,
    R? Function(Object err, StackTrace? stackTrace)? error,
  }) {
    return when(
      success: success ?? (_) => null,
      error: error ?? (err, stack) => null,
    );
  }
}
