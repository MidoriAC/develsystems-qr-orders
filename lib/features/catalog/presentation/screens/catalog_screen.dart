import 'package:develsystems_qr_orders/features/shared/widgets/producto_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';

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
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.go('/order'),
            tooltip: 'Orden',
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
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: s.items.length,
              itemBuilder: (_, i) {
                final p = s.items[i];
                return GestureDetector(
                  onTap: () => context.go('/product/${p.id}'),
                  child: ProductoContainer(product: p),
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
