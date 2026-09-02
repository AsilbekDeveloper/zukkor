import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import 'app_bottom_nav_bar.dart';

/// Asosiy ilova qobig'i — barcha yuqori darajadagi tab'lar uchun doimiy
/// pastki navigatsiya panelini ta'minlaydi.
class MainShell extends StatelessWidget {
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _onTabTap(AppTab tab) {
    navigationShell.goBranch(
      tab.index,
      // Allaqachon faol tabga qayta bosilsa, go_router standart holatda
      // hech narsa qilmaydi — xohlasa shu branch stekini shu yerda
      // tozalash (boshiga qaytarish) ham mumkin.
      initialLocation: tab.index == navigationShell.currentIndex,
    );
  }

  void _onPlayTap(BuildContext context) {
    // Markaziy "o'ynash" tugmasi — AI quiz yaratish oqimiga qisqa yo'l.
    // Bu alohida tab emas, shuning uchun hozirgi stek ustiga push qilinadi.
    context.push(AppRoutes.myAiQuizzes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        current: AppTab.values[navigationShell.currentIndex],
        onTabTap: _onTabTap,
        onPlayTap: () => _onPlayTap(context),
      ),
    );
  }
}
