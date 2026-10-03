import 'package:flutter/material.dart';

/// Wraps modal content (bottom sheets, dialogs) in a dedicated [ScaffoldMessenger]
/// and transparent [Scaffold].
///
/// This guarantees that:
/// 1. Any validation SnackBars (e.g. from AppSnackBar) triggered inside
///    the modal appear directly IN FRONT of the modal, rather than being
///    obscured behind the modal barrier or modal sheet.
/// 2. Modal content remains fully interactive without interference.
class ModalScaffoldWrapper extends StatelessWidget {
  final Widget child;

  const ModalScaffoldWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: child,
      ),
    );
  }
}
