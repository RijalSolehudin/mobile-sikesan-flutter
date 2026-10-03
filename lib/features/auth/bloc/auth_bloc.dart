import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/network/api_result.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);

    _log('AuthBloc initialized');
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'AuthBloc',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    _log('Auth check requested');
    final hasToken = await _authRepository.hasValidToken();
    if (!hasToken) {
      emit(const AuthState.unauthenticated());
      return;
    }

    final user = await _authRepository.getCachedUser();
    if (user != null) {
      _log('User loaded from cache: ${user.name} (${user.role})');
      emit(AuthState.authenticated(user));

      // Background silent verification & RBAC synchronization (TASK-CONC-11)
      final freshResult = await _authRepository.getProfile();
      if (freshResult is ApiSuccess<UserModel>) {
        if (freshResult.data != user) {
          _log(
            'User profile synced from server: ${freshResult.data.name} (${freshResult.data.role})',
          );
          emit(AuthState.authenticated(freshResult.data));
        }
      } else if (freshResult is ApiFailure<UserModel> &&
          freshResult.statusCode == 401) {
        _log('Session rejected by server during cold start handshake');
        await _authRepository.logout();
        emit(const AuthState.unauthenticated());
      }
    } else {
      _log('No valid cached user found, clearing session');
      await _authRepository.logout();
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    _log('Login requested for: ${event.username}');
    emit(const AuthState.loading());

    final result = await _authRepository.login(
      username: event.username,
      password: event.password,
    );

    if (result is ApiSuccess<UserModel>) {
      _log('Login success: ${result.data.name}');
      emit(AuthState.authenticated(result.data));
    } else if (result is ApiFailure<UserModel>) {
      _log('Login failed: ${result.message}');
      emit(AuthState.failure(result.message));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _log('Logout requested');
    emit(const AuthState.loading());
    await _authRepository.logout();
    emit(const AuthState.unauthenticated());
  }
}
