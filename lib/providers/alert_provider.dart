import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/models/alert.dart';
import 'package:shop_floor_lite/services/database_service.dart';
import 'package:shop_floor_lite/services/seed_data_service.dart';
import 'package:shop_floor_lite/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class AlertNotifier extends StateNotifier<List<Alert>> {
  final String tenantId;
  Timer? _alertGeneratorTimer;

  AlertNotifier(this.tenantId) : super([]) {
    _loadAlerts();
    _startAlertGenerator();
  }

  Future<void> _loadAlerts() async {
    final box = DatabaseService.getAlertBox();

    if (box.isEmpty) {
      final alerts = SeedDataService.getSampleAlerts(tenantId);
      for (var alert in alerts) {
        await box.add(alert);
      }
    }

    state = box.values.where((a) => a.tenantId == tenantId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _startAlertGenerator() {
    // Simulate new alerts every 2 minutes
    _alertGeneratorTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _generateRandomAlert();
    });
  }

  Future<void> _generateRandomAlert() async {
    final machines = ['M-101', 'M-102', 'M-103'];
    final titles = [
      'Temperature Alert',
      'Pressure Warning',
      'Speed Anomaly',
      'Vibration Detected',
      'Maintenance Required',
    ];
    final severities = ['low', 'medium', 'high', 'critical'];

    final randomMachine = machines[DateTime.now().millisecond % machines.length];
    final randomTitle = titles[DateTime.now().second % titles.length];
    final randomSeverity = severities[DateTime.now().minute % severities.length];

    final alert = Alert(
      id: _uuid.v4(),
      machineId: randomMachine,
      title: randomTitle,
      message: 'Automated alert for $randomMachine',
      severity: randomSeverity,
      status: 'created',
      createdAt: DateTime.now(),
      tenantId: tenantId,
    );

    final box = DatabaseService.getAlertBox();
    await box.add(alert);

    state = box.values.where((a) => a.tenantId == tenantId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> acknowledgeAlert(String alertId, String supervisorEmail) async {
    final box = DatabaseService.getAlertBox();
    final alert = box.values.firstWhere((a) => a.id == alertId);

    alert.status = 'acknowledged';
    alert.acknowledgedBy = supervisorEmail;
    alert.acknowledgedAt = DateTime.now();
    alert.isSynced = false;
    await alert.save();

    state = box.values.where((a) => a.tenantId == tenantId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> clearAlert(String alertId) async {
    final box = DatabaseService.getAlertBox();
    final alert = box.values.firstWhere((a) => a.id == alertId);

    alert.status = 'cleared';
    alert.clearedAt = DateTime.now();
    alert.isSynced = false;
    await alert.save();

    state = box.values.where((a) => a.tenantId == tenantId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  void dispose() {
    _alertGeneratorTimer?.cancel();
    super.dispose();
  }
}

final alertProvider = StateNotifierProvider<AlertNotifier, List<Alert>>((ref) {
  final user = ref.watch(authProvider);
  return AlertNotifier(user?.tenantId ?? '');
});