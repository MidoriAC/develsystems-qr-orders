import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../orders/presentation/providers/draft_providers.dart';
import '../providers/catalog_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _selectedCategory = 'Todas';

  final List<String> _categories = [
    'Todas',
    'beauty',
    'fragrances',
    'furniture',
    'groceries'
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(catalogProvider.notifier).loadCachedThenRefresh());
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(catalogProvider);
    final results = s.filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Productos'),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Buscar por nombre o marca...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (q) => ref.read(catalogProvider.notifier).setQuery(q),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                final displayNames = {
                  'Todas': 'Todas',
                  'beauty': 'Belleza',
                  'fragrances': 'Fragancias',
                  'furniture': 'Muebles',
                  'groceries': 'Abarrotes'
                };

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(displayNames[category] ?? category),
                    selected: isSelected,
                    selectedColor: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      // TODO: Crear filtro por categoria
                      // ref.read(catalogProvider.notifier).setCategory(category == 'Todas' ? null : category);
                    },
                  ),
                );
              },
            ),
          ),

          // 3. Contador de resultados
          if (s.query.isNotEmpty || _selectedCategory != 'Todas')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${results.length} resultado(s) encontrados',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),

          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No hay resultados',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final p = results[i];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: p.thumbnail != null
                                ? Image.network(
                                    p.thumbnail!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        size: 40),
                                  )
                                : const Icon(Icons.shopping_bag_outlined,
                                    size: 40),
                          ),
                          title: Text(
                            p.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${p.brand ?? 'Sin marca'} · \$${p.price.toStringAsFixed(2)}\n'
                            '${p.category?.toUpperCase()}', // Mostramos la categoría
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          isThreeLine: true,
                          onTap: () => context.go('/product/${p.id}'),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.add_shopping_cart,
                                  color: Theme.of(context).primaryColor),
                              tooltip: 'Agregar al pedido',
                              onPressed: () {
                                ref.read(draftProvider.notifier).addProduct(p);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${p.title} agregado'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
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
