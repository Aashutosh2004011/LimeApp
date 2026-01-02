import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/services/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

final pendingItemsProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.pendingItemsStream;
});