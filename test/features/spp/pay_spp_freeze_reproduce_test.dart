import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_sikesan_flutter/core/navigation/navigation_keys.dart';
import 'package:mobile_sikesan_flutter/core/navigation/modal_bottom_sheet_page.dart';
import 'package:mobile_sikesan_flutter/core/network/api_result.dart';
import 'package:mobile_sikesan_flutter/core/network/dio_client.dart';
import 'package:mobile_sikesan_flutter/data/local/secure_storage_service.dart';
import 'package:mobile_sikesan_flutter/data/models/spp_models.dart';
import 'package:mobile_sikesan_flutter/data/repositories/auth_repository.dart';
import 'package:mobile_sikesan_flutter/data/repositories/dashboard_repository.dart';
import 'package:mobile_sikesan_flutter/data/repositories/spp_repository.dart';
import 'package:mobile_sikesan_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:mobile_sikesan_flutter/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:mobile_sikesan_flutter/features/navigation/screen/main_navigation_shell.dart';
import 'package:mobile_sikesan_flutter/features/spp/bloc/spp_payment_bloc.dart';
import 'package:mobile_sikesan_flutter/features/spp/widget/pay_spp_modal.dart';
import 'package:mobile_sikesan_flutter/features/spp/widget/receipt_preview_modal.dart';

class MockSppRepo extends SppRepository {
  MockSppRepo() : super(DioClient(secureStorage: SecureStorageService()));

  @override
  Future<ApiResult<SppReceiptModel>> getReceipt(String paymentId) async {
    return const ApiSuccess(
      SppReceiptModel(
        receiptNumber: 'KW-SPP-12345678',
        paymentId: '01m40d1a7wc1j6yq8ft9xgr4rb',
        paymentDate: '2026-10-03',
        paymentTime: '08:10:37',
        totalPaidAmount: 500000,
        paymentMethod: 'CASH',
        status: 'APPROVED',
        studentName: 'Ricky Dzahir',
        studentNis: '1005',
        studentClass: '8A',
        guardianName: 'Abdul aziz',
        bills: [],
      ),
    );
  }
}

class MockAuthRepo extends AuthRepository {
  MockAuthRepo() : super(DioClient(secureStorage: SecureStorageService()), SecureStorageService());
}

class MockDashboardRepo extends DashboardRepository {
  MockDashboardRepo() : super(DioClient(secureStorage: SecureStorageService()));
}

void main() {
  testWidgets('Trigger PaySppModal success and observe navigation', (tester) async {
    final sppRepo = MockSppRepo();
    final authRepo = MockAuthRepo();
    final dashRepo = MockDashboardRepo();

    final sppBloc = SppPaymentBloc(sppRepository: sppRepo);
    final authBloc = AuthBloc(authRepository: authRepo);
    final dashBloc = DashboardBloc(dashboardRepository: dashRepo);

    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainNavigationShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () => context.push('/home/spp'),
                        child: const Text('Open Pay SPP'),
                      ),
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'spp',
                      pageBuilder: (context, state) =>
                          const ModalBottomSheetPage(child: PaySppModal()),
                      routes: [
                        GoRoute(
                          path: 'receipt',
                          pageBuilder: (context, state) {
                            final receipt = state.extra as SppReceiptModel?;
                            if (receipt == null) {
                              return const ModalBottomSheetPage(
                                child: SizedBox.shrink(),
                              );
                            }
                            return ModalBottomSheetPage(
                              child: ReceiptPreviewModal(receipt: receipt),
                            );
                          },
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'receipt',
                      pageBuilder: (context, state) {
                        final receipt = state.extra as SppReceiptModel?;
                        if (receipt == null) {
                          return const ModalBottomSheetPage(
                            child: SizedBox.shrink(),
                          );
                        }
                        return ModalBottomSheetPage(
                          child: ReceiptPreviewModal(receipt: receipt),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SppRepository>.value(value: sppRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<SppPaymentBloc>.value(value: sppBloc),
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<DashboardBloc>.value(value: dashBloc),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            scaffoldMessengerKey: rootScaffoldMessengerKey,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open Pay SPP
    await tester.tap(find.text('Open Pay SPP'));
    await tester.pumpAndSettle();
    expect(find.text('Bayar SPP'), findsOneWidget);

    // Now emit success on sppBloc
    sppBloc.emit(
      const SppPaymentState.success(
        paymentId: '01m40d1a7wc1j6yq8ft9xgr4rb',
        message: 'SPP Payment successful',
      ),
    );

    // Let the animation finish and receipt modal display
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify Receipt preview modal is now visible
    expect(find.text('Kwitansi Pembayaran'), findsOneWidget);
    expect(find.text('KW-SPP-12345678'), findsOneWidget);

    // Dismiss receipt modal
    final dynamic widgetsBinding = tester.binding;
    await widgetsBinding.handlePopRoute();
    await tester.pumpAndSettle();

    // Verify back to home without errors
    expect(find.text('Kwitansi Pembayaran'), findsNothing);
    expect(find.text('Open Pay SPP'), findsOneWidget);
  });
}
