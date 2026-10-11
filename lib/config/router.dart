import 'package:develsystems_qr_orders/features/shared/presentation/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/catalog/presentation/screens/catalog_screen.dart';
import '../features/catalog/presentation/screens/product_detail_screen.dart';
import '../features/catalog/presentation/screens/search_screen.dart';
import '../features/orders/presentation/screens/history_screen.dart';
import '../features/orders/presentation/screens/order_screen.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const CatalogScreen()),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(
          path: '/product/:id',
          builder: (_, state) => ProductDetailScreen(
              id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1),
        ),
        GoRoute(path: '/order', builder: (_, __) => const OrderScreen()),
        GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      ],
    ),
  ],
);
