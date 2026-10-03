import 'package:flutter/widgets.dart';
import 'web_history_manager.dart';

/// NavigatorObserver that tracks popup routes (modals, dialogs, bottom sheets)
/// and informs the WebHistoryManager to keep browser history synchronized.
class WebModalHistoryObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PopupRoute) {
      WebHistoryManager.instance.onModalPushed();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PopupRoute) {
      WebHistoryManager.instance.onModalPopped();
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route is PopupRoute) {
      WebHistoryManager.instance.onModalPopped();
    }
  }
}
