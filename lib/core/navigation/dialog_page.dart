import 'package:flutter/material.dart';

/// Custom Page implementation for GoRouter that displays a route
/// as a Dialog, seamlessly integrating dialogs into the browser/device
/// back navigation stack so pressing the back button dismisses the dialog.
class DialogPage<T> extends Page<T> {
  final Widget child;
  final Color? barrierColor;
  final bool barrierDismissible;

  const DialogPage({
    required this.child,
    this.barrierColor = const Color(0x80000000),
    this.barrierDismissible = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      settings: this,
      builder: (context) => child,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
    );
  }
}
