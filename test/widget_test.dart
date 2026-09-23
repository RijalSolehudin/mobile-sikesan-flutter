import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:mobile_sikesan_flutter/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:mobile_sikesan_flutter/data/repositories/spp_repository.dart';
import 'package:mobile_sikesan_flutter/main.dart';
import 'package:mobile_sikesan_flutter/router/app_router.dart';
import 'features/auth/auth_bloc_test.dart';
import 'features/dashboard/dashboard_bloc_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final mockAuthRepo = MockAuthRepository();
    final mockDashboardRepo = MockDashboardRepository();
    final mockSppRepo = SppRepository(mockDashboardRepo.dioClient);

    final authBloc = AuthBloc(authRepository: mockAuthRepo);
    final dashboardBloc = DashboardBloc(dashboardRepository: mockDashboardRepo);
    final router = AppRouter.createRouter(authBloc);

    await tester.pumpWidget(
      SikesanMobileApp(
        authRepository: mockAuthRepo,
        dashboardRepository: mockDashboardRepo,
        sppRepository: mockSppRepo,
        authBloc: authBloc,
        dashboardBloc: dashboardBloc,
        router: router,
      ),
    );

    await tester.pump();
    expect(find.byType(SikesanMobileApp), findsOneWidget);
  });
}
