import 'dart:async';
import 'package:flutter/material.dart';
import '../../features/auth/bloc/auth_bloc.dart';

class SessionTimeoutListener extends StatefulWidget {
  final Widget child;
  final AuthBloc authBloc;
  final Duration timeoutDuration;
  final void Function()? onTimeout;

  const SessionTimeoutListener({
    super.key,
    required this.child,
    required this.authBloc,
    this.timeoutDuration = const Duration(minutes: 30),
    this.onTimeout,
  });

  @override
  State<SessionTimeoutListener> createState() => _SessionTimeoutListenerState();
}

class _SessionTimeoutListenerState extends State<SessionTimeoutListener> {
  Timer? _timer;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkAndResetTimer(widget.authBloc.state);
    _authSubscription = widget.authBloc.stream.listen((state) {
      _checkAndResetTimer(state);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  bool _isBendahara(AuthState state) {
    if (!state.isAuthenticated || state.user == null) return false;
    final role = state.user!.role.toLowerCase();
    return role.contains('bendahara');
  }

  void _checkAndResetTimer(AuthState state) {
    if (_isBendahara(state)) {
      _startTimer();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeoutDuration, _handleTimeout);
  }

  void _handleTimeout() {
    if (!mounted) return;

    if (_isBendahara(widget.authBloc.state)) {
      widget.authBloc.add(const AuthLogoutRequested());
      widget.onTimeout?.call();
    }
  }

  void _onUserInteraction([_]) {
    if (_isBendahara(widget.authBloc.state)) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onUserInteraction,
      onPointerMove: _onUserInteraction,
      onPointerUp: _onUserInteraction,
      child: widget.child,
    );
  }
}
