import 'package:flutter/services.dart';

/// Stub implementation for non-web platforms (Android, iOS, desktop, unit tests).
/// All web history management operations are no-ops on native platforms where
/// Flutter natively handles hardware back buttons and system pop events.
class WebHistoryManager {
  static final WebHistoryManager instance = WebHistoryManager._();
  WebHistoryManager._();

  void init({
    required void Function() onModalPop,
    required void Function() onRootBack,
  }) {}

  void onModalPushed() {}
  void onModalPopped() {}
  void enableRootGuard() {}
  void disableRootGuard() {}

  void exitApp() {
    SystemNavigator.pop();
  }
}
