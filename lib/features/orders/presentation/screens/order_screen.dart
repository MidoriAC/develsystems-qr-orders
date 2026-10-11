import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/order.dart';
import '../providers/orders_providers.dart';

/// Pedido actual mínimo: crea pedido demo con items 1x1 para validar flujo.
/// El lector QR real (SDK) lo alimenta en el siguiente paso.
class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});
  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final List<OrderItem> _draft = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ordersProvider.notifier).init());
  }

  double get _total => _draft.fold(0, (s, e) => s + e.lineTotal);

  @override
  Widget build(BuildContext context) {
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
          children: [
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: () => setState(() => _draft.add(const OrderItem(
                      productId: 1,
                      qty: 1,
                      nameSnapshot: 'Essence Mascara (demo)',
                      priceSnapshot: 9.99))),
                  child: const Text('Agregar ID 1'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => setState(() => _draft.add(const OrderItem(
                      productId: 2,
                      qty: 1,
                      nameSnapshot: 'Apple (demo)',
                      priceSnapshot: 1.99))),
                  child: const Text('Agregar ID 2'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Total estimado: \$${_total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: _draft.isEmpty
                  ? const Center(
                      child: Text(
                          'Borrador vacío. Agrega productos o escanea un QR.'))
                  : ListView.builder(
                      itemCount: _draft.length,
                      itemBuilder: (_, i) => ListTile(
                        title: Text(_draft[i].nameSnapshot),
                        subtitle:
                            Text('ID ${_draft[i].productId} x${_draft[i].qty}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => setState(() => _draft.removeAt(i)),
                        ),
                      ),
                    ),
            ),
            FilledButton(
              onPressed: _draft.isEmpty
                  ? null
                  : () async {
                      await ref
                          .read(ordersProvider.notifier)
                          .createWithItems(List.of(_draft));
                      setState(_draft.clear);
                      if (context.mounted) context.go('/history');
                    },
              child: const Text('Guardar pedido (pendiente)'),
            ),
          ],
        ),
      ),
    );
  }
}
