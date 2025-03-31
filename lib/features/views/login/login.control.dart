import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robust/common/data/remote/result.dart';
import 'package:robust/features/data/models/token.dart';
import 'package:robust/features/data/repositories/login.repository.dart';
import 'package:robust/features/domain/repositories/login.repository.dart';

part 'login.control.g.dart';

@riverpod
$LoginRepository loginRepository(Ref ref) {
  return LoginRepository(ref);
}

@riverpod
Future<Result<Token>> login(Ref ref, {required String username}) async {
  return await ref.read(loginRepositoryProvider).login(username);
}
