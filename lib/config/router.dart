import 'package:go_router/go_router.dart';

import '../features/catalog/presentation/screens/catalog_screen.dart';
import '../features/orders/presentation/screens/history_screen.dart';
import '../features/orders/presentation/screens/order_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const CatalogScreen()),
    GoRoute(path: '/order', builder: (_, __) => const OrderScreen()),
    GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
  ],
);
