import 'package:develsystems_qr_orders/features/catalog/presentation/providers/catalog_notifier.dart';
import 'package:develsystems_qr_orders/features/catalog/presentation/providers/catalog_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:develsystems_qr_orders/config/environment.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/http/dio_client.dart';
import '../../data/datasources/catalog_local_ds.dart';
import '../../data/datasources/catalog_remote_ds.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../domain/repositories/catalog_repository.dart';

final dioProvider = Provider<Dio>((ref) =>
    buildDio(baseUrl: Environment.baseUrl, timeoutMs: Environment.timeoutMs));

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CatalogRepositoryImpl(
    local: CatalogLocalDs(() => AppDatabase.instance.db),
    remote: CatalogRemoteDs(dio),
  );
});

final catalogProvider =
    NotifierProvider<CatalogNotifier, CatalogState>(CatalogNotifier.new);
