import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/order.dart';
import '../providers/orders_providers.dart';

String labelOf(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:
      return 'Pendiente';
    case OrderStatus.sending:
      return 'Enviando';
    case OrderStatus.confirmed:
      return 'Confirmado simulado';
    case OrderStatus.error:
      return 'Error';
    case OrderStatus.unknown:
      return 'Desconocido';
  }
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ordersProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: s.isSending
                  ? null
                  : () => ref.read(ordersProvider.notifier).sendPending(),
              child: Text(s.isSending ? 'Enviando…' : 'Enviar pendientes'),
            ),
          ),
          if (s.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Error: ${s.error}',
                  style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: s.isLoading
                ? const Center(child: CircularProgressIndicator())
                : s.orders.isEmpty
                    ? const Center(
                        child: Text('Sin pedidos guardados todavía.'))
                    : ListView.builder(
                        itemCount: s.orders.length,
                        itemBuilder: (_, i) {
                          final o = s.orders[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(
                                  '${labelOf(o.status)} · \$${o.totalEstimated.toStringAsFixed(2)} estimado'),
                              subtitle: Text(
                                  '${o.items.length} líneas · intentos ${o.attempts}'
                                  '${o.remoteRef != null ? ' · ref ${o.remoteRef}' : ''}'
                                  '${o.lastError != null ? '\n${o.lastError}' : ''}'),
                              trailing: o.status == OrderStatus.unknown
                                  ? TextButton(
                                      onPressed: () => ref
                                          .read(ordersProvider.notifier)
                                          .retryUnknown(o),
                                      child: const Text('Reintentar'),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
