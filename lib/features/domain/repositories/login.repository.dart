import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robust/common/data/remote/result.dart';
import 'package:robust/features/domain/usecases/post_login.dart';
import 'package:robust/features/data/models/token.dart';
import 'package:robust/features/data/repositories/login.repository.dart';

// extends implements
class LoginRepository extends $LoginRepository {
  final Ref ref;
  final PostLogin _postLogin;

  LoginRepository(this.ref) : _postLogin = PostLogin(ref);

  @override
  Future<Result<Token>> login(String username) async {
    return _postLogin(username);
  }
}
