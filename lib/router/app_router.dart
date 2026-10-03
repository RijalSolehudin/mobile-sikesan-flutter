import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/navigation/navigation_keys.dart';
import '../core/navigation/snackbar_cleanup_observer.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/screen/login_screen.dart';
import '../features/auth/screen/role_selection_screen.dart';
import '../features/splash/screen/splash_screen.dart';
import '../features/dashboard/screen/home_screen.dart';
import '../features/mutation/screen/mutation_screen.dart';
import '../features/information/screen/information_screen.dart';
import '../features/cs_sikesan/screen/cs_screen.dart';
import '../features/profile/screen/profile_screen.dart';
import '../features/kwitansi/screen/kwitansi_screen.dart';
import '../features/navigation/screen/main_navigation_shell.dart';
import '../core/navigation/modal_bottom_sheet_page.dart';
import '../features/spp/widget/pay_spp_modal.dart';
import '../features/wallet/widget/top_up_modal.dart';
import '../features/wallet/widget/withdraw_modal.dart';
import '../features/infaq/widget/pay_infaq_modal.dart';
import '../core/navigation/dialog_page.dart';
import '../features/kwitansi/widget/create_kwitansi_modal.dart';
import '../features/kwitansi/widget/kwitansi_detail_modal.dart';
import '../features/kwitansi/models/kwitansi_model.dart';
import '../data/models/spp_models.dart';
import '../data/models/top_up_models.dart';
import '../data/models/withdraw_models.dart';
import '../features/spp/widget/receipt_preview_modal.dart';
import '../features/wallet/widget/top_up_receipt_modal.dart';
import '../features/wallet/widget/withdraw_receipt_modal.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      observers: [SnackBarCleanupObserver()],
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final loc = state.matchedLocation;
        final isSplash = loc == '/splash' || loc == '/';
        final isRoleSelection = loc == '/role-selection';
        final isLogin = loc == '/login';

        final isLoggedIn = authState.isAuthenticated;

        // If user is ALREADY logged in and attempts to access splash screen (e.g. via back button),
        // redirect immediately to /home so splash screen is NEVER shown again!
        if (isLoggedIn && isSplash) {
          return '/home';
        }

        // While on splash during cold start, let SplashScreen perform branding delay and transition
        if (isSplash) {
          return null;
        }

        // Global Splash check: while checking token or during app startup, stay on /splash
        if (authState is AuthInitial) {
          return '/splash';
        }

        // If not logged in and not on login or role-selection page, redirect to role-selection
        if (!isLoggedIn && !isLogin && !isRoleSelection) {
          return '/role-selection';
        }

        // If logged in and on login/role-selection, redirect to home
        if (isLoggedIn && (isLogin || isRoleSelection)) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 450),
          ),
        ),
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 450),
          ),
        ),
        GoRoute(
          path: '/role-selection',
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) {
            final initialRole = state.extra as String?;
            return LoginScreen(initialRole: initialRole);
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainNavigationShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
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
                      path: 'top-up',
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>?;
                        return ModalBottomSheetPage(
                          child: TopUpModal(
                            preselectedStudentId: extra?['studentId'] as int?,
                            preselectedStudentName:
                                extra?['studentName'] as String?,
                          ),
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'receipt',
                          pageBuilder: (context, state) {
                            final receipt = state.extra as TopUpReceiptModel?;
                            if (receipt == null) {
                              return const ModalBottomSheetPage(
                                child: SizedBox.shrink(),
                              );
                            }
                            return ModalBottomSheetPage(
                              child: TopUpReceiptModal(receipt: receipt),
                            );
                          },
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'withdraw',
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>?;
                        return ModalBottomSheetPage(
                          child: WithdrawModal(
                            preselectedStudentId: extra?['studentId'] as int?,
                            preselectedStudentName:
                                extra?['studentName'] as String?,
                          ),
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'receipt',
                          pageBuilder: (context, state) {
                            final receipt =
                                state.extra as WithdrawReceiptModel?;
                            if (receipt == null) {
                              return const ModalBottomSheetPage(
                                child: SizedBox.shrink(),
                              );
                            }
                            return ModalBottomSheetPage(
                              child: WithdrawReceiptModal(receipt: receipt),
                            );
                          },
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'infaq',
                      pageBuilder: (context, state) =>
                          const ModalBottomSheetPage(child: PayInfaqModal()),
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
                    GoRoute(
                      path: 'kwitansi',
                      builder: (context, state) => const KwitansiScreen(),
                      routes: [
                        GoRoute(
                          path: 'create',
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>?;
                            return DialogPage(
                              child: CreateKwitansiModal(
                                existingCategories: (extra?['categories']
                                        as List<String>?) ??
                                    const ['Pondok'],
                                onCreated: (extra?['onCreated'] as Function(
                                        KwitansiModel, String?)?) ??
                                    (kwitansi, category) {},
                              ),
                            );
                          },
                        ),
                        GoRoute(
                          path: 'detail',
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>?;
                            final item = extra?['item'] as KwitansiModel?;
                            if (item == null) {
                              return const DialogPage(child: SizedBox.shrink());
                            }
                            return DialogPage(
                              child: KwitansiDetailModal(
                                item: item,
                                onDeleted: extra?['onDeleted'] as VoidCallback?,
                                onUpdated: extra?['onUpdated']
                                    as Function(KwitansiModel)?,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: '/kwitansi',
                  builder: (context, state) => const KwitansiScreen(),
                  routes: [
                    GoRoute(
                      path: 'create',
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>?;
                        return DialogPage(
                          child: CreateKwitansiModal(
                            existingCategories: (extra?['categories']
                                    as List<String>?) ??
                                const ['Pondok'],
                            onCreated: (extra?['onCreated'] as Function(
                                    KwitansiModel, String?)?) ??
                                (kwitansi, category) {},
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'detail',
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>?;
                        final item = extra?['item'] as KwitansiModel?;
                        if (item == null) {
                          return const DialogPage(child: SizedBox.shrink());
                        }
                        return DialogPage(
                          child: KwitansiDetailModal(
                            item: item,
                            onDeleted: extra?['onDeleted'] as VoidCallback?,
                            onUpdated: extra?['onUpdated']
                                as Function(KwitansiModel)?,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/mutation',
                  builder: (context, state) => const MutationScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/information',
                  builder: (context, state) => const InformationScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/cs',
                  builder: (context, state) => const CsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    router.routerDelegate.addListener(() {
      rootScaffoldMessengerKey.currentState?.clearSnackBars();
    });

    return router;
  }
}
