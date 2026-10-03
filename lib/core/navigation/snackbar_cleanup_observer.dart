import 'package:flutter/widgets.dart';
import 'navigation_keys.dart';

/// NavigatorObserver that automatically dismisses any active or queued
/// SnackBars whenever route navigation occurs (push, pop, or replace).
///
/// This eliminates "phantom" SnackBars that linger across different screens,
/// providing an optimal and non-intrusive user experience.
class SnackBarCleanupObserver extends NavigatorObserver {
  void _clearSnackBars() {
    rootScaffoldMessengerKey.currentState?.clearSnackBars();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _clearSnackBars();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _clearSnackBars();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _clearSnackBars();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _clearSnackBars();
  }
}
