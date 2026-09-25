import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/network/api_result.dart';
import 'package:mobile_sikesan_flutter/core/network/dio_client.dart';
import 'package:mobile_sikesan_flutter/data/local/secure_storage_service.dart';
import 'package:mobile_sikesan_flutter/data/models/user_model.dart';
import 'package:mobile_sikesan_flutter/data/repositories/auth_repository.dart';
import 'package:mobile_sikesan_flutter/features/auth/bloc/auth_bloc.dart';

class MockAuthRepository extends AuthRepository {
  bool hasToken = false;
  UserModel? mockUser;
  ApiResult<UserModel>? loginResult;

  MockAuthRepository()
    : super(
        DioClient(secureStorage: SecureStorageService()),
        SecureStorageService(),
      );

  @override
  Future<bool> hasValidToken() async => hasToken;

  @override
  Future<UserModel?> getCachedUser() async => mockUser;

  @override
  Future<ApiResult<UserModel>> login({
    required String username,
    required String password,
  }) async {
    return loginResult ??
        const ApiSuccess(
          UserModel(
            id: 1,
            name: 'Wali Demo',
            username: 'wali_123',
            email: 'wali@example.com',
            role: 'Wali Santri',
          ),
        );
  }

  @override
  Future<void> logout() async {
    hasToken = false;
    mockUser = null;
  }
}

void main() {
  group('AuthBloc Unit Tests', () {
    late MockAuthRepository mockRepo;
    late AuthBloc authBloc;

    setUp(() {
      mockRepo = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockRepo);
    });

    tearDown(() {
      authBloc.close();
    });

    test('Initial state is AuthStatus.initial', () {
      expect(authBloc.state.status, AuthStatus.initial);
    });

    test(
      'AuthCheckRequested emits unauthenticated when no token is present',
      () async {
        mockRepo.hasToken = false;

        authBloc.add(const AuthCheckRequested());

        await expectLater(
          authBloc.stream,
          emits(const AuthState(status: AuthStatus.unauthenticated)),
        );
      },
    );

    test(
      'AuthCheckRequested emits authenticated when token and user exist',
      () async {
        const user = UserModel(
          id: 99,
          name: 'Bapak Ahmad',
          username: 'ahmad',
          email: 'ahmad@example.com',
          role: 'Wali Santri',
        );
        mockRepo.hasToken = true;
        mockRepo.mockUser = user;

        authBloc.add(const AuthCheckRequested());

        await expectLater(
          authBloc.stream,
          emits(const AuthState(status: AuthStatus.authenticated, user: user)),
        );
      },
    );

    test(
      'AuthLoginRequested emits loading then authenticated on success',
      () async {
        const user = UserModel(
          id: 1,
          name: 'Kasir Sikesan',
          username: 'kasir_1',
          email: 'kasir@example.com',
          role: 'Kasir',
        );
        mockRepo.loginResult = const ApiSuccess(user);

        authBloc.add(
          const AuthLoginRequested(username: 'kasir_1', password: '123'),
        );

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.loading),
            const AuthState(status: AuthStatus.authenticated, user: user),
          ]),
        );
      },
    );

    test(
      'AuthLoginRequested emits loading then failure on ApiFailure',
      () async {
        mockRepo.loginResult = const ApiFailure(
          'Username atau password salah',
          statusCode: 401,
        );

        authBloc.add(
          const AuthLoginRequested(username: 'wrong', password: 'bad'),
        );

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.loading),
            const AuthState(
              status: AuthStatus.failure,
              errorMessage: 'Username atau password salah',
            ),
          ]),
        );
      },
    );

    test('AuthLogoutRequested emits loading then unauthenticated', () async {
      authBloc.add(const AuthLogoutRequested());

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.unauthenticated),
        ]),
      );
    });
  });
}
