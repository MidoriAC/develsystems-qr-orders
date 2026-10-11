import 'package:develsystems_qr_orders/features/orders/presentation/providers/orders_notifier.dart';
import 'package:develsystems_qr_orders/features/orders/presentation/providers/orders_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../data/datasources/orders_local_ds.dart';
import '../../data/datasources/orders_remote_ds.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OrdersRepositoryImpl(
    local: OrdersLocalDs(() => AppDatabase.instance.db),
    remote: OrdersRemoteDs(dio),
  );
});

final ordersProvider =
    NotifierProvider<OrdersNotifier, OrdersState>(OrdersNotifier.new);
