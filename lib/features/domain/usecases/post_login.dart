import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:robust/app/di/di.dart';
import 'package:robust/common/data/remote/result.dart';
import 'package:robust/common/data/usecases.dart';
import 'package:robust/features/data/models/token.dart';


class PostLogin extends UseCase<String, Result<Token>> {
  late final api = ref.read(apiProvider);

  PostLogin(super.ref);

  @override
  Future<Result<Token>> executeRemote(String param) async {
    String user = 'user';
    String password = 'password';
    String auth = 'Basic ${base64Encode(utf8.encode('$user:$password'))}';
    Options options = Options(headers: {'authorization': auth});

    return await api.get(
      endpoint: 'art/token',
      queryParameters: {'device_id': param},
      fromJson: (json) => Token.fromJson(json),
      options: options,
    );
  }
}
