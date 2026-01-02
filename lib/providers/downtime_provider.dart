import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/models/downtime.dart';
import 'package:shop_floor_lite/services/database_service.dart';
import 'package:shop_floor_lite/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class DowntimeNotifier extends StateNotifier<List<Downtime>> {
  final String tenantId;

  DowntimeNotifier(this.tenantId) : super([]) {
    _loadDowntimes();
  }

  Future<void> _loadDowntimes() async {
    final box = DatabaseService.getDowntimeBox();
    state = box.values.where((d) => d.tenantId == tenantId).toList();
  }

  Future<Downtime> startDowntime({
    required String machineId,
    required String reasonCode,
    String? reasonSubCode,
    required String operatorEmail,
    String? photoPath,
  }) async {
    final downtime = Downtime(
      id: _uuid.v4(),
      machineId: machineId,
      reasonCode: reasonCode,
      reasonSubCode: reasonSubCode,
      startTime: DateTime.now(),
      photoPath: photoPath,
      tenantId: tenantId,
      operatorEmail: operatorEmail,
    );

    final box = DatabaseService.getDowntimeBox();
    await box.add(downtime);

    state = [...state, downtime];
    return downtime;
  }

  Future<void> endDowntime(String downtimeId) async {
    final box = DatabaseService.getDowntimeBox();
    final downtime = box.values.firstWhere((d) => d.id == downtimeId);

    downtime.endTime = DateTime.now();
    downtime.isSynced = false;
    await downtime.save();

    state = box.values.where((d) => d.tenantId == tenantId).toList();
  }

  Downtime? getActiveDowntimeForMachine(String machineId) {
    try {
      return state.firstWhere((d) => d.machineId == machineId && d.isActive);
    } catch (e) {
      return null;
    }
  }

  List<Downtime> getDowntimesForMachine(String machineId) {
    return state.where((d) => d.machineId == machineId).toList();
  }
}

final downtimeProvider = StateNotifierProvider<DowntimeNotifier, List<Downtime>>((ref) {
  final user = ref.watch(authProvider);
  return DowntimeNotifier(user?.tenantId ?? '');
});