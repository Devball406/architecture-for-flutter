import 'package:robust/common/data/remote/result.dart';
import 'package:robust/features/data/models/token.dart';

abstract class $LoginRepository {
  Future<Result<Token>> login(String username);
}
