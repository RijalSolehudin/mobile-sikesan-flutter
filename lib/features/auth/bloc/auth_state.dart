part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(UserModel user) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.failure(String message) = AuthFailure;

  UserModel? get user => maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );

  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isLoading => this is AuthLoading;
}
