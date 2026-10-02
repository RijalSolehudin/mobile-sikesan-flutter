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

class _SessionTimeoutListenerState extends State<SessionTimeoutListener>
    with WidgetsBindingObserver {
  Timer? _timer;
  StreamSubscription<AuthState>? _authSubscription;
  DateTime? _backgroundTimestamp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndResetTimer(widget.authBloc.state);
    _authSubscription = widget.authBloc.stream.listen((state) {
      _checkAndResetTimer(state);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isBendahara(widget.authBloc.state)) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundTimestamp = DateTime.now();
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTimestamp != null) {
        final elapsed = DateTime.now().difference(_backgroundTimestamp!);
        if (elapsed >= widget.timeoutDuration) {
          _backgroundTimestamp = null;
          _handleTimeout();
          return;
        }
      }
      _backgroundTimestamp = null;
      _startTimer();
    }
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
