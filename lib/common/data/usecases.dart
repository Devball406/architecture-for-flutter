import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 表示无参数的标记类，用于不需要参数的 UseCase
class NoParams {
  const NoParams();
}

/// 全局常量，用于不需要参数的 UseCase
const noParams = NoParams();

abstract class UseCase<P, T> {
  final Ref ref;

  UseCase(this.ref);

  /// 从远程数据源获取数据
  Future<T> executeRemote(P param);

  /// 从本地数据源获取数据 (可选实现)
  Future<T?> executeLocal(P params) async => null;

  /// 检查本地数据是否有效 (可选实现)
  bool isLocalDataValid(T local) => false;

  /// 更新数据到本地 (可选实现)
  Future<void> updates(T item) async {}

  /// 执行 UseCase 的主要入口
  /// [params] 调用参数
  /// [preferLocal] 是否优先使用本地数据 (默认为 true)
  /// [forceRefresh] 是否强制刷新，忽略本地缓存 (默认为 false)
  Future<T> call(
    P params, {
    bool preferLocal = true,
    bool forceRefresh = false,
  }) async {
    try {
      // 如果不需要强制刷新，尝试从本地获取
      if (!forceRefresh && preferLocal) {
        final local = await executeLocal(params);
        if (local != null && isLocalDataValid(local)) {
          return local;
        }
      }

      // 从远程获取数据
      final remote = await executeRemote(params);

      // 更新本地缓存
      await updates(remote);

      return remote;
    } catch (error, stackTrace) {
      // 可以在这里添加统一的错误处理逻辑
      // 例如日志记录或错误转换
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
