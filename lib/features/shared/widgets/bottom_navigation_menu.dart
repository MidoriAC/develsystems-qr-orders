import 'package:develsystems_qr_orders/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:develsystems_qr_orders/features/orders/presentation/providers/draft_providers.dart';
import 'package:develsystems_qr_orders/features/scan/presentation/scan_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_bridge/qr_bridge.dart';

class BottomNavigationMenu extends ConsumerStatefulWidget {
  const BottomNavigationMenu({super.key});

  @override
  ConsumerState<BottomNavigationMenu> createState() =>
      _BottomNavigationMenuState();
}

class _BottomNavigationMenuState extends ConsumerState<BottomNavigationMenu> {
  Future<void> _scan() async {
    try {
      final id = await ref.read(qrBridgeProvider).scanProduct();
      final product = await ref.read(catalogRepositoryProvider).findById(id);
      if (!mounted) return;
      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Producto $id no encontrado o no disponible sin conexión')),
        );
        return;
      }
      ref.read(draftProvider.notifier).addProduct(product);
    } on QrScanException catch (e) {
      if (!mounted || e.code == QrScanCodes.cancelled) return;
      final msg = switch (e.code) {
        QrScanCodes.permissionDenied =>
          'Permiso de cámara denegado. Concédelo para escanear.',
        QrScanCodes.cameraUnavailable =>
          'Cámara no disponible en este momento.',
        QrScanCodes.invalidQr =>
          'QR inválido. Usa el formato product:{id} (ej. product:1).',
        QrScanCodes.scanInProgress => 'Ya hay una lectura en curso.',
        _ => 'Error de lectura: ${e.message}',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _calculateSelectedIndex(location);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home,
                  isSelected: currentIndex == 0,
                  onTap: () => context.go('/'),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.search,
                  isSelected: currentIndex == 1,
                  onTap: () => context.go('/'),
                ),
                const SizedBox(width: 60),
                _buildNavItem(
                  context,
                  icon: Icons.history,
                  isSelected: currentIndex == 2,
                  onTap: () => context.go('/history'),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.shopping_cart,
                  isSelected: currentIndex == 3,
                  onTap: () => context.go('/'),
                ),
              ],
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () => _scan(),
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    return -1;
  }
}
