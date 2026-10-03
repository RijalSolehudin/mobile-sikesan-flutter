import 'package:flutter/material.dart';

/// Custom Page implementation for GoRouter that displays a route
/// as a ModalBottomSheet, seamlessly syncing modal display with
/// the browser/device back navigation stack.
class ModalBottomSheetPage<T> extends Page<T> {
  final Widget child;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final bool useSafeArea;

  const ModalBottomSheetPage({
    required this.child,
    this.isScrollControlled = true,
    this.backgroundColor = Colors.transparent,
    this.useSafeArea = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      builder: (context) => child,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      useSafeArea: useSafeArea,
      settings: this,
    );
  }
}
