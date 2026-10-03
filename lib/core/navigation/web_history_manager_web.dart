import 'dart:js_interop';

@JS('sikesanPushModal')
external void _sikesanPushModal();

@JS('sikesanPopModal')
external void _sikesanPopModal();

@JS('sikesanRegisterPopHandler')
external void _sikesanRegisterPopHandler(JSFunction callback);

@JS('sikesanRegisterRootBackHandler')
external void _sikesanRegisterRootBackHandler(JSFunction callback);

@JS('sikesanEnableRootGuard')
external void _sikesanEnableRootGuard();

@JS('sikesanDisableRootGuard')
external void _sikesanDisableRootGuard();

@JS('sikesanExitApp')
external void _sikesanExitApp();

/// Web implementation of WebHistoryManager using dart:js_interop.
/// Coordinates modal stack depth and rootpage back gestures with browser history.
class WebHistoryManager {
  static final WebHistoryManager instance = WebHistoryManager._();
  WebHistoryManager._();

  bool _initialized = false;
  bool isHandlingBrowserPop = false;

  void init({
    required void Function() onModalPop,
    required void Function() onRootBack,
  }) {
    if (_initialized) return;
    _initialized = true;

    try {
      _sikesanRegisterPopHandler((() {
        isHandlingBrowserPop = true;
        try {
          onModalPop();
        } finally {
          isHandlingBrowserPop = false;
        }
      }).toJS);

      _sikesanRegisterRootBackHandler((() {
        onRootBack();
      }).toJS);
    } catch (_) {}
  }

  void onModalPushed() {
    try {
      _sikesanPushModal();
    } catch (_) {}
  }

  void onModalPopped() {
    try {
      _sikesanPopModal();
    } catch (_) {}
  }

  void enableRootGuard() {
    try {
      _sikesanEnableRootGuard();
    } catch (_) {}
  }

  void disableRootGuard() {
    try {
      _sikesanDisableRootGuard();
    } catch (_) {}
  }

  void exitApp() {
    try {
      _sikesanExitApp();
    } catch (_) {}
  }
}
