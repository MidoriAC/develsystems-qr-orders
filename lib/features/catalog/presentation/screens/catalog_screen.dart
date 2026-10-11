import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../orders/presentation/providers/draft_providers.dart';
import '../providers/catalog_providers.dart';

/// Catálogo: lee SQLite, estados carga/vacío/error/offline (§2 UI).
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});
  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(catalogProvider.notifier).loadCachedThenRefresh());
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          if (s.isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Chip(label: Text('Offline')),
            ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => context.go('/history'),
            tooltip: 'Historial',
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (s.isLoading && s.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      s.isOffline
                          ? 'Sin datos ni conexión. Conéctate una vez para descargar el catálogo.'
                          : 'Sin productos. Revisa tu conexión e inténtalo de nuevo.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref
                          .read(catalogProvider.notifier)
                          .loadCachedThenRefresh(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(catalogProvider.notifier).loadCachedThenRefresh(),
            child: ListView.builder(
              itemCount: s.items.length,
              itemBuilder: (_, i) {
                final p = s.items[i];
                return ListTile(
                  leading: p.thumbnail != null
                      ? Image.network(p.thumbnail!,
                          width: 48,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported))
                      : const Icon(Icons.shopping_bag_outlined),
                  title: Text(p.title),
                  subtitle: Text(
                      'ID ${p.id} · \$${p.price.toStringAsFixed(2)} (estimado)'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart_outlined),
                    tooltip: 'Agregar al pedido',
                    onPressed: () {
                      ref.read(draftProvider.notifier).addProduct(p);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${p.title} agregado'),
                          action: SnackBarAction(
                            label: 'Ver pedido',
                            onPressed: () => context.go('/order'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/order'),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Pedido'),
      ),
    );
  }
}
