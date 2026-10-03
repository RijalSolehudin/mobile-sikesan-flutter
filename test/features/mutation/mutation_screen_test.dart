import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/network/api_result.dart';
import 'package:mobile_sikesan_flutter/core/network/dio_client.dart';
import 'package:mobile_sikesan_flutter/data/local/secure_storage_service.dart';
import 'package:mobile_sikesan_flutter/data/models/transaction_item_model.dart';
import 'package:mobile_sikesan_flutter/data/models/user_model.dart';
import 'package:mobile_sikesan_flutter/data/repositories/auth_repository.dart';
import 'package:mobile_sikesan_flutter/data/repositories/dashboard_repository.dart';
import 'package:mobile_sikesan_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:mobile_sikesan_flutter/features/mutation/screen/mutation_screen.dart';
import 'package:mobile_sikesan_flutter/features/mutation/widget/mutation_item_tile.dart';

class MockDashboardRepository extends DashboardRepository {
  final Map<int, List<TransactionItemModel>> pageData;

  MockDashboardRepository({required this.pageData})
    : super(DioClient(secureStorage: SecureStorageService()));

  @override
  Future<ApiResult<List<TransactionItemModel>>> getRecentTransactions({
    int page = 1,
    int perPage = 15,
    int? month,
    int? year,
    int? studentId,
  }) async {
    final list = pageData[page] ?? [];
    return ApiSuccess(list);
  }

  @override
  Future<ApiResult<List<TransactionItemModel>>> getSppTransactions({
    bool isGuardian = true,
    int page = 1,
    int perPage = 15,
    int? month,
    int? year,
  }) async {
    return ApiSuccess(pageData[page] ?? []);
  }

  @override
  Future<ApiResult<List<TransactionItemModel>>> getInfaqTransactions({
    bool isGuardian = true,
    int page = 1,
    int perPage = 15,
    int? month,
    int? year,
  }) async {
    return ApiSuccess(pageData[page] ?? []);
  }
}

class MockAuthRepository extends AuthRepository {
  MockAuthRepository()
    : super(
        DioClient(secureStorage: SecureStorageService()),
        SecureStorageService(),
      );

  @override
  Future<bool> hasValidToken() async => true;

  @override
  Future<UserModel?> getCachedUser() async => const UserModel(
    id: 1,
    name: 'Wali Santri Demo',
    username: 'wali',
    email: 'wali@example.com',
    role: 'Wali Santri',
  );
}

void main() {
  group('MutationScreen Widget Tests', () {
    final page1Transactions = List.generate(
      15,
      (i) => TransactionItemModel(
        id: 'tx-page1-$i',
        title: 'Transaksi Page 1 Item $i',
        amount: 25000.0 * (i + 1),
        date: DateTime.now().subtract(Duration(minutes: i * 10)),
        isIncome: i % 2 == 0,
        category: 'Uang Saku',
        studentName: 'Santri $i',
      ),
    );

    final page2Transactions = List.generate(
      5,
      (i) => TransactionItemModel(
        id: 'tx-page2-$i',
        title: 'Transaksi Page 2 Item $i',
        amount: 15000.0 * (i + 1),
        date: DateTime.now().subtract(Duration(hours: 5 + i)),
        isIncome: true,
        category: 'Uang Saku',
        studentName: 'Santri Lanjutan $i',
      ),
    );

    testWidgets(
      'renders initial transactions and supports lazy loading on scroll',
      (tester) async {
        final mockRepo = MockDashboardRepository(
          pageData: {1: page1Transactions, 2: page2Transactions},
        );

        final authBloc = AuthBloc(authRepository: MockAuthRepository())
          ..emit(
            const AuthState.authenticated(
              UserModel(
                id: 1,
                name: 'Wali Demo',
                username: 'wali',
                email: 'wali@test.com',
                role: 'Wali Santri',
              ),
            ),
          );

        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: [
              RepositoryProvider<DashboardRepository>.value(value: mockRepo),
            ],
            child: MultiBlocProvider(
              providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
              child: const MaterialApp(home: MutationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Ensure tabs and initial items are rendered
        expect(find.text('Uang Saku'), findsOneWidget);
        expect(find.text('Pembayaran SPP'), findsOneWidget);
        expect(find.text('Infak Kesantrian'), findsOneWidget);

        // Verify that initial page items are rendered
        expect(find.byType(MutationItemTile), findsWidgets);
        expect(find.text('Transaksi Page 1 Item 0'), findsOneWidget);

        // Trigger lazy load scroll
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -3000),
        );
        await tester.pumpAndSettle();

        // Verify that page 2 items are now loaded and rendered
        expect(find.text('Transaksi Page 2 Item 0'), findsOneWidget);
        expect(find.text('Semua transaksi telah dimuat'), findsOneWidget);

        authBloc.close();
      },
    );

    testWidgets(
      'renders MutationPeriodFilter and displays month/year options',
      (tester) async {
        final mockRepo = MockDashboardRepository(
          pageData: {1: page1Transactions},
        );

        final authBloc = AuthBloc(authRepository: MockAuthRepository())
          ..emit(
            const AuthState.authenticated(
              UserModel(
                id: 1,
                name: 'Wali Demo',
                username: 'wali',
                email: 'wali@test.com',
                role: 'Wali Santri',
              ),
            ),
          );

        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: [
              RepositoryProvider<DashboardRepository>.value(value: mockRepo),
            ],
            child: MultiBlocProvider(
              providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
              child: const MaterialApp(home: MutationScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Ensure period filter dropdowns are rendered
        expect(find.text('Semua Bulan'), findsOneWidget);
        expect(find.text('Semua Tahun'), findsOneWidget);

        authBloc.close();
      },
    );
  });
}
