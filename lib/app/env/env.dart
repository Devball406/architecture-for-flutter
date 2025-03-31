import 'package:envied/envied.dart';

part 'env.g.dart';

final AppEnv env = AppEnv();

@Envied(path: '.env.dev', name: 'DevEnv')
@Envied(path: '.env.prod', name: 'ProdEnv', obfuscate: true)
class AppEnv {
  static const bool kDebugMode = true;

  factory AppEnv() => _instance;

  static final AppEnv _instance = kDebugMode ? _DevEnv() : _ProdEnv();

  @EnviedField(varName: 'KEY')
  final String key = _instance.key;

  @EnviedField(varName: 'API_KEY')
  final String apiKey = _instance.apiKey;

  @EnviedField(varName: 'BASE_URL')
  final String baseUrl = _instance.baseUrl;
}
