import 'package:develsystems_qr_orders/features/shared/widgets/bottom_navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: child,
        bottomNavigationBar: const BottomNavigationMenu(),
      ),
    );
  }
}
