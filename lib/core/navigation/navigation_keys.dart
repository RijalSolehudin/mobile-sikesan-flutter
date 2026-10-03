import 'package:flutter/material.dart';

/// Global navigation and messaging keys used across the application
/// to enable clean architecture decoupling of UI effects and routing.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();
