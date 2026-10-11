import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_bridge/qr_bridge.dart';

import '../providers/draft_providers.dart';
import '../providers/orders_providers.dart';
import '../../../scan/presentation/scan_providers.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';

/// Pedido actual: borrador compartido con catálogo.
class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});
  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ordersProvider.notifier).init();
      ref.read(catalogProvider.notifier).loadCachedThenRefresh();
    });
  }

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
    final draft = ref.watch(draftProvider);
    final items = draft.values.toList();
    final total = ref.read(draftProvider.notifier).total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido actual'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: _scan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear QR'),
            ),
            const SizedBox(height: 12),
            Text('Total estimado: \$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                          'Borrador vacío. Agrega desde el catálogo o escanea un QR.'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final it = items[i];
                        return ListTile(
                          title: Text(it.nameSnapshot),
                          subtitle: Text(
                              'ID ${it.productId} · \$${it.priceSnapshot.toStringAsFixed(2)} c/u'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => ref
                                    .read(draftProvider.notifier)
                                    .decrement(it.productId),
                              ),
                              Text('${it.qty}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => ref
                                    .read(draftProvider.notifier)
                                    .increment(it.productId),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            FilledButton(
              onPressed: items.isEmpty
                  ? null
                  : () async {
                      await ref
                          .read(ordersProvider.notifier)
                          .createWithItems(items);
                      ref.read(draftProvider.notifier).clear();
                      if (context.mounted) context.go('/history');
                    },
              child: const Text('Guardar pedido'),
            ),
          ],
        ),
      ),
    );
  }
}
