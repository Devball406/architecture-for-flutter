import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

// Generic AsyncValueWidget to work with values of type T
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.asyncValue,
    required this.contentBuilder,
    this.errorBuilder,
  });

  // input async value
  final AsyncValue<T> asyncValue;

  // output builder function
  final Widget Function(T) contentBuilder;
  final Widget Function(Object error, StackTrace stackTrace)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: contentBuilder,
      error: errorBuilder ?? (e, _) => Text(e.toString()).center(),
      loading: () => const CircularProgressIndicator().center(),
    );
  }
}
