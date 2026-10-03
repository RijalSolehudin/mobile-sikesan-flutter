import 'package:flutter/material.dart';
import '../../../core/navigation/navigation_keys.dart';
import '../../../core/navigation/web_history_manager.dart';
import '../../cs_sikesan/screen/cs_screen.dart';
import '../../dashboard/screen/home_screen.dart';
import '../../information/screen/information_screen.dart';
import '../../mutation/screen/mutation_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../widget/custom_curved_bottom_bar.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;
  final List<Widget>? tabs;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
    this.tabs,
  });

  static void switchToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationShellState>();
    state?.setTab(index);
  }

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WebHistoryManager.instance.init(
      onModalPop: () {
        if (rootNavigatorKey.currentState?.canPop() ?? false) {
          rootNavigatorKey.currentState?.pop();
        }
      },
      onRootBack: () {
        _handleBackPress();
      },
    );
    WebHistoryManager.instance.enableRootGuard();
  }

  @override
  void dispose() {
    WebHistoryManager.instance.disableRootGuard();
    super.dispose();
  }

  void setTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _handleBackPress() {
    // 1. Prioritas 1: Jika ada modal/dialog/sheet aktif di root navigator -> tutup modal teratas
    final isShellCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (!isShellCurrent && (rootNavigatorKey.currentState?.canPop() ?? false)) {
      rootNavigatorKey.currentState?.pop();
      return;
    }

    // 2. Prioritas 2: Jika ada sub-halaman di navigator -> pop sub-halaman
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    // 3. Prioritas 3: Berada di rootpage dari tab manapun (Beranda, Mutasi, Info, CS, Profil)
    // -> Konfirmasi keluar aplikasi (double back press)
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

    // Menutup aplikasi jika ditekan 2x dalam 2 detik di rootpage
    WebHistoryManager.instance.disableRootGuard();
    WebHistoryManager.instance.exitApp();
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
        body: IndexedStack(
          index: _currentIndex,
          children: widget.tabs ??
              const [
                HomeScreen(),
                MutationScreen(),
                InformationScreen(),
                CsScreen(),
                ProfileScreen(),
              ],
        ),
        bottomNavigationBar: CustomCurvedBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setTab(index);
          },
        ),
      ),
    );
  }
}
