import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef VoidAsyncValue = AsyncValue<void>;

extension AsyncValueUi on VoidAsyncValue {
  //是否是正在加载
  bool get isLoading => this is AsyncLoading<void>;

  void showSnackBarOnError(BuildContext context) => whenOrNull(
        error: (message, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.toString())),
          );
        },
      );
}
