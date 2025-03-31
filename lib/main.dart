import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robust/common/data/remote/network_error.dart';

import 'app/routes/routes.dart';
import 'common/data/local/storage.dart';
import 'common/event_bus.dart';

void main() async {
  await local.ensureInitialized();
  runApp(ProviderScope(child: RobustApp()));
}

class RobustApp extends StatefulWidget {
  const RobustApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RobustAppState();
  }
}

class _RobustAppState extends State<RobustApp> with _NetworkErrorHandle {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: setupRoutes,
    );
  }
}

/// 全局网络错误处理混入
mixin _NetworkErrorHandle on State<RobustApp> {
  StreamSubscription<NetworkError>? _mSubscription;

  @override
  void initState() {
    super.initState();
    _setupNetworkErrorListener();
  }

  @override
  void dispose() {
    _mSubscription?.cancel();
    super.dispose();
  }

  void _setupNetworkErrorListener() {
    _mSubscription = eventBus.on<NetworkError>().listen(_handleNetworkError);
  }

  void _handleNetworkError(NetworkError error) {
    if (!mounted) return;

    // 根据错误类型执行不同操作
    switch (error.code) {
      case 401: // 未授权
        _handleUnauthorizedError();
        break;
      case 403: // 禁止访问
        _handleForbiddenError();
        break;
      case 500: // 服务器错误
        _handleServerError(error);
        break;
      case 503: // 服务不可用
        _handleServiceUnavailable(error);
        break;
      default:
        _showGenericErrorDialog(error);
    }
  }

  void _handleUnauthorizedError() {
    // 清除用户数据
    // context.read(authProvider.notifier).logout();
    // 跳转到登录页面
    LoginRoute().pushReplacement(context);
  }

  void _handleForbiddenError() {
    LoginRoute().pushReplacement(context);
  }

  void _handleServerError(NetworkError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server Error'),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleServiceUnavailable(NetworkError error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Service Unavailable'),
        content: const Text(
            'Our servers are currently under maintenance. Please try again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showGenericErrorDialog(NetworkError error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
