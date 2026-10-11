import 'package:develsystems_qr_orders/features/orders/presentation/providers/draft_providers.dart';
import 'package:flutter/material.dart';
import 'package:develsystems_qr_orders/features/catalog/domain/entities/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductoContainer extends ConsumerStatefulWidget {
  final Product product;
  const ProductoContainer({super.key, required this.product});

  @override
  ConsumerState<ProductoContainer> createState() => _ProductoContainerState();
}

class _ProductoContainerState extends ConsumerState<ProductoContainer> {
  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: p.thumbnail != null
                  ? Image.network(
                      p.thumbnail!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.image_not_supported)),
                    )
                  : const Center(
                      child: Icon(Icons.shopping_bag_outlined, size: 48)),
            ),
          ),
          // Detalles del producto
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${p.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600),
                    ),
                    InkWell(
                      onTap: () {
                        ref.read(draftProvider.notifier).addProduct(p);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${p.title} agregado')),
                        );
                      },
                      child: const Icon(Icons.add_shopping_cart,
                          size: 20, color: Colors.grey),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
