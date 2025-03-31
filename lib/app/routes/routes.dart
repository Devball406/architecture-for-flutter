import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:robust/features/views/screens.dart';

part 'routes.g.dart';

final _naviKey = GlobalKey<NavigatorState>();
final _shellNaviKey = GlobalKey<NavigatorState>();

final GoRouter setupRoutes = GoRouter(
  initialLocation: '/login',
  debugLogDiagnostics: true,
  navigatorKey: _naviKey,
  routes: $appRoutes,
);

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  @override
  Widget build(context, state) => const LoginScreen();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = _naviKey;
}

@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData {
  @override
  Widget build(context, state) => const HomeScreen();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = _naviKey;
}
