import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robust/app/env/env.dart';
import 'package:robust/common/data/remote/network.dart';

part 'di.g.dart';

@riverpod
Dio dio(Ref ref) {
  final options = BaseOptions(baseUrl: env.baseUrl);
  return Dio(options);
}

@riverpod
Restpool api(Ref ref) {
  return Restpool(ref.read(dioProvider));
}
