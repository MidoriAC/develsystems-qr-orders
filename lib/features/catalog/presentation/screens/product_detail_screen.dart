import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../orders/presentation/providers/draft_providers.dart';
import '../providers/catalog_providers.dart';

/// Detalle de producto por ID (lee la caché local; funciona offline
/// si el producto ya fue descargado).
class ProductDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const ProductDetailScreen({super.key, required this.id});
  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notifier = ref.read(catalogProvider.notifier);
      await notifier.loadCachedThenRefresh();
      // Si no está en caché, intenta traerlo por red (examen §4).
      if (mounted &&
          ref.read(catalogProvider).items.every((p) => p.id != widget.id)) {
        await ref.read(catalogRepositoryProvider).findById(widget.id);
        await notifier.loadCachedThenRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(catalogProvider).items;
    final match = items.where((p) => p.id == widget.id);
    if (match.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text('Producto ${widget.id}'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'))),
        body: const Center(
            child: Text(
                'Producto no encontrado o no disponible sin conexión.')),
      );
    }
    final p = match.first;
    return Scaffold(
      appBar: AppBar(
        title: Text('#${p.id} ${p.title}'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (p.images.isNotEmpty)
            SizedBox(
              height: 200,
              child: PageView(
                children: p.images
                    .take(5)
                    .map((u) => Image.network(u,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported, size: 64)))
                    .toList(),
              ),
            ),
          const SizedBox(height: 12),
          Text('\$${p.price.toStringAsFixed(2)} (estimado)',
              style: Theme.of(context).textTheme.headlineSmall),
          if (p.rating != null) Text('★ ${p.rating}'),
          const SizedBox(height: 8),
          if (p.description != null) Text(p.description!),
          const SizedBox(height: 12),
          _row('Marca', p.brand ?? '—'),
          _row('Categoría', p.category ?? '—'),
          _row('SKU', p.sku ?? '—'),
          _row('Stock', p.stock?.toString() ?? '—'),
          _row('Disponibilidad', p.availabilityStatus ?? '—'),
          if (p.discountPercentage != null)
            _row('Descuento', '${p.discountPercentage}%'),
          if (p.tags.isNotEmpty) _row('Etiquetas', p.tags.join(', ')),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ref.read(draftProvider.notifier).addProduct(p);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${p.title} agregado al pedido')));
              context.go('/order');
            },
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: const Text('Agregar al pedido'),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 130,
                child: Text(k,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text(v)),
          ],
        ),
      );
}
