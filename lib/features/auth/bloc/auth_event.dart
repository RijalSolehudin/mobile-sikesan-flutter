part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkRequested() = AuthCheckRequested;

  const factory AuthEvent.loginRequested({
    required String username,
    required String password,
  }) = AuthLoginRequested;

  const factory AuthEvent.logoutRequested() = AuthLogoutRequested;
}
