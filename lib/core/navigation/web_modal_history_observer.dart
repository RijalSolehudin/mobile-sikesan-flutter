import 'package:flutter/widgets.dart';

/// Legacy observer preserved for backwards compatibility.
///
/// Modals, dialogs, bottom sheets, and dropdowns are managed natively by
/// Flutter's [Navigator] stack. Directly invoking browser history.pushState
/// and history.back on modal/dropdown push/pop conflicts with GoRouter's
/// RouteInformationProvider, triggering spurious page reloads and re-push cycles.
class WebModalHistoryObserver extends NavigatorObserver {}
