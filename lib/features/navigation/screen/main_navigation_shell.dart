import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/navigation_keys.dart';
import '../widget/custom_curved_bottom_bar.dart';

class MainNavigationShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  DateTime? _lastBackPressTime;

  void _handleBackPress() {
    // 1. Prioritas 1: Jika ada modal/dialog/sheet aktif di root navigator -> tutup modal
    // Pastikan hanya pop rootNavigator jika ada overlay/dialog di atas MainNavigationShell
    // (isCurrent == false). Jika shell isCurrent, me-pop rootNavigator akan mengeluarkan
    // shell dan kembali ke Splash/Login!
    final isShellCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (!isShellCurrent && (rootNavigatorKey.currentState?.canPop() ?? false)) {
      rootNavigatorKey.currentState?.pop();
      return;
    }

    // 2. Prioritas 1b: Jika ada sub-rute atau modal aktif di branch navigator -> pop rute tersebut
    final branchNav =
        widget.navigationShell.shellRouteContext.navigatorKey.currentState;
    if (branchNav != null && branchNav.canPop()) {
      branchNav.pop();
      return;
    }

    // Prioritas 2: Jika posisi BUKAN di tab Beranda (index != 0) -> kembali ke Beranda (index 0)
    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return;
    }

    // Prioritas 3: Jika sudah di Beranda dan tidak ada modal/sub-rute -> Konfirmasi keluar aplikasi
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      rootScaffoldMessengerKey.currentState?.removeCurrentSnackBar();
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Tekan sekali lagi untuk keluar dari aplikasi'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Menutup aplikasi jika ditekan 2x dalam 2 detik di halaman Beranda
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: CustomCurvedBottomBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (index) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}

