import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shop_floor_lite/services/database_service.dart';
import 'package:shop_floor_lite/models/downtime.dart';
import 'package:shop_floor_lite/models/maintenance.dart';
import 'package:shop_floor_lite/models/alert.dart';

class SyncService {
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final _syncController = StreamController<int>.broadcast();

  Stream<int> get pendingItemsStream => _syncController.stream;
  bool _isSyncing = false;

  void initialize() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi)) {
        syncPendingItems();
      }
    });

    // Initial sync check
    _checkAndSync();
  }

  Future<void> _checkAndSync() async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi)) {
      await syncPendingItems();
    }
  }

  int getPendingItemsCount() {
    int count = 0;

    final downtimes = DatabaseService.getDowntimeBox().values;
    count += downtimes.where((d) => !d.isSynced).length;

    final maintenances = DatabaseService.getMaintenanceBox().values;
    count += maintenances.where((m) => !m.isSynced).length;

    final alerts = DatabaseService.getAlertBox().values;
    count += alerts.where((a) => !a.isSynced).length;

    return count;
  }

  Future<void> syncPendingItems() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final result = await _connectivity.checkConnectivity();
      if (!result.contains(ConnectivityResult.mobile) &&
          !result.contains(ConnectivityResult.wifi)) {
        _isSyncing = false;
        return;
      }

      // Simulate API sync with delay
      await Future.delayed(const Duration(seconds: 2));

      // Sync downtimes
      final downtimeBox = DatabaseService.getDowntimeBox();
      final unsyncedDowntimes = downtimeBox.values.where((d) => !d.isSynced).toList();
      for (var downtime in unsyncedDowntimes) {
        await _syncDowntime(downtime);
      }

      // Sync maintenance tasks
      final maintenanceBox = DatabaseService.getMaintenanceBox();
      final unsyncedMaintenance = maintenanceBox.values.where((m) => !m.isSynced).toList();
      for (var task in unsyncedMaintenance) {
        await _syncMaintenance(task);
      }

      // Sync alerts
      final alertBox = DatabaseService.getAlertBox();
      final unsyncedAlerts = alertBox.values.where((a) => !a.isSynced).toList();
      for (var alert in unsyncedAlerts) {
        await _syncAlert(alert);
      }

      _syncController.add(getPendingItemsCount());
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncDowntime(Downtime downtime) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 100));

    // Mark as synced
    downtime.isSynced = true;
    await downtime.save();
  }

  Future<void> _syncMaintenance(MaintenanceTask task) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 100));

    // Mark as synced
    task.isSynced = true;
    await task.save();
  }

  Future<void> _syncAlert(Alert alert) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 100));

    // Mark as synced
    alert.isSynced = true;
    await alert.save();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncController.close();
  }
}