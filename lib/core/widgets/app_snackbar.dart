import 'package:flutter/material.dart';
import '../navigation/navigation_keys.dart';
import '../theme/app_colors.dart';

enum SnackBarType { success, error, warning, info }

/// Standardized, best-practice SnackBar helper for SIKESAN.
///
/// Features:
/// - Automatically calls [clearSnackBars] before showing a new SnackBar,
///   preventing unwanted message queuing when buttons are tapped multiple times.
/// - Distinct styling, colors, and iconography per [SnackBarType].
/// - Clean architecture decoupled from any specific screen.
class AppSnackBar {
  AppSnackBar._();

  static const Duration _defaultDuration = Duration(milliseconds: 2500);

  /// Shows a customized SnackBar with auto-clear of previous snackbars.
  static void show(
    BuildContext? context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = (context != null && context.mounted)
        ? ScaffoldMessenger.maybeOf(context) ??
              rootScaffoldMessengerKey.currentState
        : rootScaffoldMessengerKey.currentState;

    if (messenger == null) return;

    // 1. Immediately purge any active or queued snackbars
    messenger.clearSnackBars();

    // 2. Select visual appearance based on type
    final config = _getStyle(type);

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: config.backgroundColor,
      duration: duration ?? _defaultDuration,
      dismissDirection: DismissDirection.horizontal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: config.borderColor, width: 1),
      ),
      content: Row(
        children: [
          Icon(config.icon, color: config.iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                messenger.hideCurrentSnackBar();
                onAction();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    // 3. Present the new snackbar immediately
    messenger.showSnackBar(snackBar);
  }

  /// Convenience method for error notifications
  static void showError(
    BuildContext? context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Convenience method for success notifications
  static void showSuccess(
    BuildContext? context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Convenience method for warning notifications
  static void showWarning(
    BuildContext? context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Convenience method for informational notifications
  static void showInfo(
    BuildContext? context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Immediately clear all active and pending SnackBars
  static void clear(BuildContext? context) {
    final messenger = (context != null && context.mounted)
        ? ScaffoldMessenger.maybeOf(context) ??
              rootScaffoldMessengerKey.currentState
        : rootScaffoldMessengerKey.currentState;
    messenger?.clearSnackBars();
  }

  static _SnackBarConfig _getStyle(SnackBarType type) {
    switch (type) {
      case SnackBarType.error:
        return const _SnackBarConfig(
          backgroundColor: Color(0xFFDC2626), // Tailwind Red 600
          borderColor: Color(0xFFB91C1C),
          iconColor: Colors.white,
          icon: Icons.error_outline_rounded,
        );
      case SnackBarType.success:
        return const _SnackBarConfig(
          backgroundColor: Color(0xFF15803D), // Forest Green
          borderColor: Color(0xFF166534),
          iconColor: Colors.white,
          icon: Icons.check_circle_outline_rounded,
        );
      case SnackBarType.warning:
        return const _SnackBarConfig(
          backgroundColor: Color(0xFFD97706), // Amber 600
          borderColor: Color(0xFFB45309),
          iconColor: Colors.white,
          icon: Icons.warning_amber_rounded,
        );
      case SnackBarType.info:
        return const _SnackBarConfig(
          backgroundColor: Color(0xFF1E293B), // Slate 800
          borderColor: Color(0xFF0F172A),
          iconColor: AppColors.primaryLight,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _SnackBarConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;

  const _SnackBarConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
  });
}
