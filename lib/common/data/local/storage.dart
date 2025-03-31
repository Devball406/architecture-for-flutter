import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

final Local local = Local.singleton();

abstract class _$Local {
  T get<T>(String key, [T? defaultValue]);

  Future<void> put(String key, dynamic value);

  Future<void> delete(String key);

  Future<void> clear();
}

class Local extends _$Local {
  static final Local _instance = Local._();

  factory Local.singleton() {
    return _instance;
  }

  late SharedPreferencesWithCache _prefs;
  final _initCompleter = Completer<SharedPreferencesWithCache>();

  Local._() {
    _initCompleter.complete(SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(),
    ));
  }

  Future<void> ensureInitialized() async {
    _prefs = await _initCompleter.future;
  }

  @override
  T get<T>(String key, [T? defaultValue]) {
    assert(
      T == String || T == int || T == bool || T == double || T == List<String>,
      'Unsupported type: $T. Supported types are String, int, bool, double, and List<String>',
    );

    final value = _prefs.get(key);
    if (value == null) return defaultValue as T;

    return value as T;
  }

  @override
  Future<void> put(String key, dynamic value) async {
    await ensureInitialized();

    if (value == null) {
      return delete(key);
    }

    return switch (value.runtimeType) {
      const (int) => _prefs.setInt(key, value),
      const (bool) => _prefs.setBool(key, value),
      const (double) => _prefs.setDouble(key, value),
      List<String>() => _prefs.setStringList(key, value),
      _ => _prefs.setString(key, value.toString()),
    };
  }

  @override
  Future<void> delete(String key) async {
    return _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}
